
"""
Slack chat-bot Lambda handler.
"""
import boto3
import collections
import json
import os
import hmac
import hashlib
import logging
from urllib.parse import unquote_plus
from datetime import datetime

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

# Set global defaults
BOT_TOKEN = os.environ["SLACK_API_TOKEN"]
SLACK_SIGNING_SECRET = os.environ['SLACK_SIGNING_SECRET']
SLACK_URL = "https://slack.com/api/chat.postMessage"

s3 = boto3.client('s3')


def get_http_response(httpStatusCode, body, headers={}):
    return {
        "isBase64Encoded": False,
        "statusCode": httpStatusCode,
        "headers": headers,
        "body": body
        }


def get_slack_payload(event):
    try:
        payload = unquote_plus(event['body-json']).strip("payload=")
        payload = json.loads(payload)
        event['payload'] = payload
        return event
    except TypeError as e:
        log.error(f"Event was not in the expected format: {e}")


def build_sfn_message(s3_key, slack_payload):
    msg = {}
    button_value = json.loads(slack_payload['actions'][0]['value'])
    msg['button_pressed'] = slack_payload['actions'][0]['action_id']
    msg['slack_message_key'] = s3_key
    msg['ldap_scan_results'] = button_value['ldap_scan_results']
    return {
        "message": msg,
        "task_token": button_value['task_token']
    }


def notify_stepfunction(message, task_token):
    """Sends a task token to the step function service and sets the
    slack response as the output of the sfn task waiting on the token
    """
    sfn = boto3.client("stepfunctions")
    log.debug("Sending message to stepfunctions")
    response = sfn.send_task_success(
        taskToken=task_token,
        output=json.dumps(message)
    )
    log.debug(f"Received response from stepfunctions: {response}")


# borrowed largely from here:
# https://github.com/codelabsab/timereport-slack/blob/master/chalicelib/lib/slack.py
def verify_token(event, signing_secret):
    """
    https://api.slack.com/docs/verifying-requests-from-slack
    1. Grab timestamp and slack signature from headers.
    2. Concat and create a signature with timestamp + body
    3. Hash the signature together with
        your signing_secret token from slack settings
    4. Compare digest to slack signature from header
    """
    request_timestamp = event['params']['header']['X-Slack-Request-Timestamp']
    slack_signature = event['params']['header']['X-Slack-Signature']

    request_basestring = f"v0:{request_timestamp}:{event['body-json']}"
    my_sig = hmac.new(
        bytes(signing_secret, "utf-8"),
        bytes(request_basestring, "utf-8"),
        hashlib.sha256).hexdigest()
    my_sig = f'v0={my_sig}'

    assert hmac.compare_digest(my_sig, slack_signature), (
        "The provided slack response cannot be validated. "
        "Confirm the provided slack signing secret is correct "
        "or resend the message."
    )


def put_object(dest_bucket_name, dest_object_name, src_data):
    """
    Add an object to an Amazon S3 bucket
    """

    # Construct Body= parameter
    if isinstance(src_data, bytes):
        object_data = src_data
    else:
        log.error(
            f"Type of {str(type(src_data))}"
            f" for the argument \'src_data\' is not supported.")
        return False

    # Put the object
    s3 = boto3.client('s3')
    # log.debug(f"destination object name: {dest_object_name}")
    try:
        s3.put_object(
            Bucket=dest_bucket_name,
            ACL="private",
            Key=dest_object_name,
            Body=object_data
            )
    except s3.exceptions.ClientError as e:
        # AllAccessDisabled error == bucket not found
        # NoSuchKey or InvalidRequest
        # error == (dest bucket/obj == src bucket/obj)
        log.error(e)
        return False
    finally:
        if isinstance(src_data, str):
            object_data.close()
    return True


def s3upload(
    object_content,
    prefix="slack-response",
    bucket=os.environ['ARTIFACTS_BUCKET']
):
    timestamp = datetime.now().strftime("%Y-%m-%d-T%H%M%S.%f")
    object_name = f"{prefix}-{timestamp}.json"
    log.debug(f'Uploading object: {object_name} to {bucket}')
    put_object(
            bucket,
            object_name,
            json.dumps(object_content).encode("utf-8"))
    return object_name


def handler(event, context):
    log.debug(f"received event: {event}")

    # parse the slack payload
    event = get_slack_payload(event)
    log.debug(f"received slack payload: {event}")

    # verify the slack payload
    verify_token(event, SLACK_SIGNING_SECRET)

    # upload the payload to s3
    s3_key = s3upload(event['payload'])

    # send button status to the stepfunction
    msg = build_sfn_message(s3_key, event['payload'])
    notify_stepfunction(**msg)
