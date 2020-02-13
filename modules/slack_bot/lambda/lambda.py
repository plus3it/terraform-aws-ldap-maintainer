"""
Slack chat-bot Lambda handler.
"""
import boto3
import collections
import json
import logging
import os
import random
import re
import string
from urllib.parse import parse_qs

import slack

DEFAULT_LOG_LEVEL = logging.DEBUG
LOG_LEVELS = collections.defaultdict(
    lambda: DEFAULT_LOG_LEVEL,
    {
        "critical": logging.CRITICAL,
        "error": logging.ERROR,
        "warning": logging.WARNING,
        "info": logging.INFO,
        "debug": logging.DEBUG,
    },
)

# Lambda initializes a root logger that needs to be removed in order to set a
# different logging config
root = logging.getLogger()
if root.handlers:
    for handler in root.handlers:
        root.removeHandler(handler)

log_file_name = ""
if not os.environ.get("AWS_EXECUTION_ENV"):
    log_file_name = "slack_listener.log"

logging.basicConfig(
    filename=log_file_name,
    format="%(asctime)s.%(msecs)03dZ [%(name)s][%(levelname)-5s]: %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%S",
    level=LOG_LEVELS[os.environ.get("LOG_LEVEL", "").lower()],
)
log = logging.getLogger(__name__)


slack_client = slack.WebClient(token=os.environ["SLACK_API_TOKEN"])
s3 = boto3.client("s3")
sfn = boto3.client("stepfunctions")


def get_http_response(httpStatusCode, body=None, headers={}):
    return {
        "isBase64Encoded": False,
        "statusCode": httpStatusCode,
        "headers": headers,
        "body": body,
    }


def start_sfn(
    sfn_arn=os.environ["SFN_ARN"], name="slackbot", sfn_input={"action": "query"}
):
    random_string = "".join(random.choices(string.ascii_uppercase + string.digits, k=5))
    return sfn.start_execution(
        stateMachineArn=sfn_arn,
        name=f"{name}-{random_string}",
        input=json.dumps(sfn_input),
    )


def get_sfn_status(sfn_arn=os.environ["SFN_ARN"]):
    return sfn.list_executions(
        stateMachineArn=sfn_arn, statusFilter="RUNNING", maxResults=0
    )


def stop_sfn():
    running_sfns = get_sfn_status()["executions"]
    for running_sfn in running_sfns:
        execution_arn = running_sfn["executionArn"]
        sfn.stop_execution(
            executionArn=execution_arn,
            error="Slackbot stop",
            cause="Stop execution event initiated from slack",
        )


def get_last_modified():
    return lambda obj: int(obj["LastModified"].strftime("%s"))


def get_latest_s3_object(
    bucket=os.environ["ARTIFACTS_BUCKET"], prefix="user_expiration"
):
    """
    Retrieve the newest object in the target s3 bucket
    """
    response = s3.list_objects_v2(Bucket=bucket, Prefix=prefix)
    all = response["Contents"]
    return max(all, key=lambda x: x["LastModified"])


def create_presigned_url(bucket_name, object_name, expiration=3600):
    return s3.generate_presigned_url(
        "get_object",
        Params={
            "Bucket": bucket_name,
            "Key": object_name,
            "ResponseContentType": "text/html",
        },
        ExpiresIn=expiration,
    )


def get_user_report():
    latest_user_expiration_report = get_latest_s3_object()["Key"]
    log.debug("latest user expiration report object: %s", latest_user_expiration_report)
    url = create_presigned_url(
        os.environ["ARTIFACTS_BUCKET"], latest_user_expiration_report
    )
    return f"latest report: <{url}|{latest_user_expiration_report}>"


def message_check(pattern, message_string, flags=re.IGNORECASE):
    message_check = re.compile(pattern, flags)
    return message_check.search(message_string)


def send_slack_message(message, bot_text):
    user = message["user"]
    channel = message["channel"]

    if message.get("ephemeral"):
        slack_client.chat_postEphemeral(channel=channel, text=bot_text, user=user)
    else:
        slack_client.chat_postMessage(channel=channel, text=bot_text)


def parse_slack_message(message):
    log.debug("processing user message: %s", message)
    # unwrap any lists left over from parse_qs
    for key in message:
        if type(message[key]) == list:
            message[key] = message[key][0]
    # make the slash command format 'match' a chat message
    if message.get("command"):
        message["ephemeral"] = True
        message["user"] = message["user_id"]
        message["channel"] = message["channel_id"]
    return message


def slack_message_handler(message):
    message = parse_slack_message(message)
    text = message["text"]
    user = message["user"]

    bot_text = "Sorry, I didn't understand that command"

    if message_check("hi", text):
        bot_text = f"Hi <@{user}> :wave:"

    if message_check("(?:help|\?)", text):
        bot_text = """
        I support the follwing commands:
        *cancel|stop*: Cancels the current execution
        *start|run*: Starts a new scan
        *help|?*: this help menu
        """

    if message_check("(?:cancel|stop)", text):
        stop_sfn()
        bot_text = "Current run cancelled"

    if message_check("(?:start|run)", text):
        start_sfn()
        bot_text = "New scan started"

    if message_check("report", text):
        bot_text = get_user_report()

    send_slack_message(message, bot_text)
    return get_http_response(200)


def handler(event, context):
    log.debug("received event: %s", event)

    try:
        slack_message = json.loads(event["body"])
    except TypeError:
        # added for testing with vanilla json
        slack_message = event["body"]
    except json.JSONDecodeError:
        # assume that the body came from a slash command
        slack_message = parse_qs(event["body"])

    if not slack_message:
        log.debug("Message received was not from slack or was improperly formatted.")
        return get_http_response(200)

    if slack_message.get("challenge"):
        log.debug("Responding to challenge message.")
        return get_http_response(200, {"challenge": slack_message["challenge"]})

    if slack_message.get("event"):
        slack_message = slack_message["event"]

        # ignore bot's own message
        if slack_message.get("message") and slack_message["message"].get("bot_id"):
            log.debug("Received bot's own message. ignoring..")
            return get_http_response(200)

    return slack_message_handler(slack_message)
