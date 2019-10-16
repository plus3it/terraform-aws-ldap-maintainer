
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
import re
from urllib.parse import unquote
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

# Grab the Bot OAuth token from the environment.
BOT_TOKEN = os.environ["SLACK_API_TOKEN"]

# Define the URL of the targeted Slack API resource.
# We'll send our replies there.
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
    """
    Extract the body data of the slack request.

    Somewhere between API GW > SQS > lambda the response from slack gets
    converted to JSON. Unfortunately, the conversion to a python-readable
    object is not possible due to the presence of invalid characters in the
    resulting object. This function tries to set things right..
    """
    event_body = event['Records'][0]['body'].replace("\n", "")
    log.debug(f'event body pre-search: {event_body}')
    payload = re.search(r'(\"payload=)(.*)(\"\,\"params\" \:)', event_body)
    params = re.search(r'(\"\,\"params\" \:)(.*)(\,\")', event_body)
    try:
        if payload and params:
            payload = payload.group(2)
            params = params.group(2)
            log.debug(f"payload: {payload}")
            log.debug(f"params: {params}")
            response = {}
            response['payload'] = json.loads(payload)
            response['params'] = json.loads(params)
            return response
        else:
            log.error("Invalid payload received!")
            exit
    except IndexError:
        log.error("Invalid payload received!")
        exit
    except json.decoder.JSONDecodeError:
        log.error("Invalid payload received!")
        exit


def notify_stepfunction(slack_payload):
    """Sends a task token to the step function service and sets the
    slack response as the output of the sfn task waiting on the token

    """
    slack_payload['button_pressed'] = slack_payload['actions'][0]['action_id']
    task_token = unquote(slack_payload['actions'][0]['value'])
    sfn = boto3.client("stepfunctions")
    log.debug("Sending slack_payload to stepfunctions")
    response = sfn.send_task_success(
        taskToken=task_token,
        output=json.dumps(slack_payload)
    )
    log.debug(f"Received response from stepfunctions: {response}")


def validate_user(slack_payload):
    """Confirm if the user taking the action has the right."""
    return True


# borrowed largely from here:
# https://github.com/codelabsab/timereport-slack/blob/master/chalicelib/lib/slack.py
def verify_token(headers, body, signing_secret):
    """
    https://api.slack.com/docs/verifying-requests-from-slack
    1. Grab timestamp and slack signature from headers.
    2. Concat and create a signature with timestamp + body
    3. Hash the signature together with
        your signing_secret token from slack settings
    4. Compare digest to slack signature from header
    """
    request_timestamp = headers['X-Slack-Request-Timestamp'][0]
    slack_signature = headers['X-Slack-Signature'][0]

    request_basestring = f'v0:{request_timestamp}:{body}'
    my_sig = hmac.new(
        bytes(signing_secret, "utf-8"),
        bytes(request_basestring, "utf-8"),
        hashlib.sha256).hexdigest()
    my_sig = f'v0={my_sig}'

    if hmac.compare_digest(my_sig, slack_signature):
        return True
    else:
        return False


def get_reserialized_payload(event):
    for key in event:
        event[key] = key.encode()
    return event


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


def handler(event, context):
    log.debug(f"received event: {event}")
    # parse the slack payload
    event = get_slack_payload(event)
    log.debug(f"received slack payload: {event}")
    # upload the payload to s3
    s3upload(event['payload'])
    # send button status to the stepfunction
    notify_stepfunction(event['payload'])

    # validate the message received from slack and that
    # the user is authorized to take the action

    # SLACK_SIGNING_SECRET = os.environ['SLACK_SIGNING_SECRET']
    # user_id = event['payload']['user']['id']
    # headers = event['params']['header']

    # serialized_payload = get_reserialized_payload(event['payload'])
    # log.debug(f"serialized_payload: {serialized_payload}")
    # log.debug(f"{verify_token(
    #   headers,
    #   serialized_payload,
    #   SLACK_SIGNING_SECRET)}")

    # if verify_token(slack_headers, event['body'], SLACK_SIGNING_SECRET):
    #     slack_payload = get_slack_payload(event)
    #     if verify_user(slack_payload):
    #         notify_stepfunction(slack_payload)
    #     else:
    #         message = "Sorry, you must be a member of X group to do that."
