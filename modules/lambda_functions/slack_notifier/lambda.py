import boto3
import collections
import dateutil.tz
import json
import logging
import os
from datetime import datetime

import slack


DEFAULT_LOG_LEVEL = logging.DEBUG
LOG_LEVELS = collections.defaultdict(
    lambda: DEFAULT_LOG_LEVEL,
    {
        'critical': logging.CRITICAL,
        'error': logging.ERROR,
        'warning': logging.WARNING,
        'info': logging.INFO,
        'debug': logging.DEBUG
    }
)

# Lambda initializes a root logger that needs to be removed in order to set a
# different logging config
root = logging.getLogger()
if root.handlers:
    for handler in root.handlers:
        root.removeHandler(handler)

log_file_name = ""
if not os.environ.get("AWS_EXECUTION_ENV"):
    log_file_name = 'ldap_maintainer_slack.log'

logging.basicConfig(
    filename=log_file_name,
    format='%(asctime)s.%(msecs)03dZ [%(name)s][%(levelname)-5s]: %(message)s',
    datefmt='%Y-%m-%dT%H:%M:%S',
    level=LOG_LEVELS[os.environ.get('LOG_LEVEL', '').lower()])
log = logging.getLogger(__name__)


SLACK_API_TOKEN = os.environ['SLACK_API_TOKEN']
s3 = boto3.client('s3')


def get_time():
    eastern = dateutil.tz.gettz(os.environ['TIMEZONE'])
    return datetime.now(tz=eastern).strftime("%m/%d/%Y, %H:%M:%S")


class SlackMessageBuilder:
    """Constructs slack messages"""

    INVOKE_BASE_URL = os.environ['INVOKE_BASE_URL']

    HEADER_BLOCK = {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "A scan of our LDAP directory has been completed."
            }
        }

    DIVIDER_BLOCK = {"type": "divider"}

    CONFIRMATION_BLOCK = {
        "title": {
            "type": "plain_text",
            "text": "Are you sure?"
        },
        "text": {
            "type": "mrkdwn",
            "text": "Are you sure you want to take this action?"
        },
        "confirm": {
            "type": "plain_text",
            "text": "Yes"
        },
        "deny": {
            "type": "plain_text",
            "text": "No"
        }
        }

    def __init__(
            self,
            channel,
            artifacts,
            user_counts,
            report_time,
            task_token):
        self.channel = channel
        self.username = "ldapmaintainerbot"
        self.icon_emoji = ":robot_face:"
        self.timestamp = get_time()
        self.artifacts = artifacts
        self.user_counts = user_counts
        self.report_time = report_time
        self.task_token = task_token
        self.ldap_scan_results = ""

    def get_message_payload(self):
        return {
            "ts": self.timestamp,
            "channel": self.channel,
            "username": self.username,
            "icon_emoji": self.icon_emoji,
            "blocks": [
                self.HEADER_BLOCK,
                self.DIVIDER_BLOCK,
                self._get_artifact_urls_block(),
                self.DIVIDER_BLOCK,
                # self._get_button_header_block(),
                self._get_buttons_block(),
                self._get_context_block()
            ]
        }

    def _get_artifact_urls_block(self):
        text = (
            f"Total counts of users with passwords"
            f" that have not been changed in.."
            f"\n\t greater than 120 days: {self.user_counts['120']}"
            f"\n\t gerater than 90 days: {self.user_counts['90']}"
            f"\n\t greater than 60 days: {self.user_counts['60']}"
            )
        human_readable = ""
        machine_readable = ""
        for artifact in self.artifacts:
            file_name = artifact["file_name"]
            url = artifact["url"]
            if not artifact['raw_scan_results']:
                human_readable += f"\n <{url}|{file_name}> \n"
            else:
                self.ldap_scan_results = file_name
                machine_readable += f"\n <{url}|{file_name}> \n"
        text += (
            f"\n\n human readable details available here: "
            f"{human_readable}"
            f"\n\n machine readable details available here: "
            f"{machine_readable}"
            f"\n *Note*: When this message is 1 hour old these"
            f" urls will no longer be functional\n\n")
        return self._get_text_block(text)

    def _get_context_block(self):
        return {
            "type": "context",
            "elements": [
                {
                    "type": "mrkdwn",
                    "text": f"Report Generated: {self.report_time}"
                }
            ]
        }

    @staticmethod
    def _get_button_header_block():
        return {
            "type": "context",
            "elements": [
                {
                    "type": "mrkdwn",
                    "text": (
                        f"\n Select Approve or Deny to"
                        f" disable the accounts that"
                        f" have not updated their passwords"
                        f" in greater than 120 days"
                        )
                }
            ]
        }

    def _get_buttons_block(self):
        return {
            "type": "actions",
            "elements": self._get_buttons()
        }

    def _get_buttons(self):
        actions = ["deny", "approve"]
        buttons = []
        button_value = json.dumps(
            {
                "task_token": self.task_token,
                "ldap_scan_results": self.ldap_scan_results
            }
        )
        for action in actions:
            if action == "approve":
                style = "primary"
            else:
                style = "danger"
            buttons.append(
                self._get_button(
                    action.capitalize(),
                    button_value,
                    style
                )
            )
        return buttons

    def _get_button(self, text, value, style):
        return {
            "type": "button",
            "text": {"type": "plain_text", "text": text},
            "value": value,
            "action_id": text,
            "confirm": self.CONFIRMATION_BLOCK,
            "style": style
            }

    @staticmethod
    def _get_text_block(text):
        return {"type": "section", "text": {"type": "mrkdwn", "text": text}}


def build_slack_user_message(event):
    TARGET_CHANNEL = os.environ['SLACK_CHANNEL_ID']
    task_token = event['token']
    payload = event['event']['Payload']
    message_body = SlackMessageBuilder(
        channel=TARGET_CHANNEL,
        artifacts=payload['artifacts'],
        user_counts=payload['query_results']['totals'],
        report_time=datetime.now().strftime("%m/%d/%Y, %H:%M:%S"),
        task_token=task_token
    )
    return message_body.get_message_payload()


def build_slack_response_message(original_blocks, msg):
    """Sends a response message to slack."""
    updated_blocks = original_blocks[0:4]
    del updated_blocks[3]
    updated_blocks.append(
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": msg
            }
        }
    )
    updated_blocks.append(original_blocks[5])
    return updated_blocks


def send_updated_message_to_slack(channel_id, timestamp, message_blocks):
    client = slack.WebClient(token=SLACK_API_TOKEN)
    response = client.chat_update(
        channel=channel_id,
        ts=timestamp,
        blocks=message_blocks
    )
    log.debug(f"Received response from slack: {response}")
    assert response["ok"]


def send_message_to_slack(message):
    """Sends the user status report to slack."""
    client = slack.WebClient(token=SLACK_API_TOKEN)
    response = client.chat_postMessage(**message)
    assert response["ok"]


def get_last_modified():
    return lambda obj: int(obj['LastModified'].strftime('%s'))


def get_latest_s3_object(
    bucket=os.environ['ARTIFACTS_BUCKET'],
    prefix='slack-response'
):
    """
    Retrieve the newest object in the target s3 bucket
    """
    response = s3.list_objects_v2(
        Bucket=bucket,
        Prefix=prefix)
    all = response['Contents']
    return max(all, key=lambda x: x['LastModified'])


def retrieve_s3_object_contents(
    s3_obj,
    bucket=os.environ['ARTIFACTS_BUCKET']
):
    return json.loads(s3.get_object(
        Bucket=bucket,
        Key=s3_obj
        )['Body'].read().decode('utf-8'))


def handler(event, context):
    log.debug(f"Received event: {json.dumps(event)}")
    if event.get('message_to_slack'):
        message = event['message_to_slack']
        response = retrieve_s3_object_contents(event['slack_message_key'])
        # When updating an existing slack message the
        # entire message must be modified and re-sent
        original_blocks = response['message']['blocks']
        channel_id = response['channel']['id']
        timestamp = response['message']['ts']
        slack_message = (
            build_slack_response_message(
                original_blocks=original_blocks,
                msg=message
            )
        )
        send_updated_message_to_slack(
            channel_id=channel_id,
            timestamp=timestamp,
            message_blocks=slack_message
        )
    else:
        slack_message = build_slack_user_message(event)
        send_message_to_slack(slack_message)
    return event
