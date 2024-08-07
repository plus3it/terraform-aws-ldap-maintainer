"""DynamoDB Cleaner

Removes specified user emails from a target DynamoDB table

Returns:
    null
"""

import collections
import json
import logging
import os

import boto3

s3 = boto3.client("s3")

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
    for log_handler in root.handlers:
        root.removeHandler(log_handler)

LOG_FILE_NAME = ""
if not os.environ.get("AWS_EXECUTION_ENV"):
    LOG_FILE_NAME = "dynamodb_cleanup.log"

logging.basicConfig(
    filename=LOG_FILE_NAME,
    format="%(asctime)s.%(msecs)03dZ [%(name)s][%(levelname)-5s]: %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%S",
    level=LOG_LEVELS[os.environ.get("LOG_LEVEL", "").lower()],
)
log = logging.getLogger(__name__)


dynamodb = boto3.client("dynamodb")
dynamodb_resource = boto3.resource("dynamodb")
table = dynamodb_resource.Table(os.environ["DYNAMODB_TABLE"])


def scan_table(scan_attributes):
    """Scan the target table by attribute list."""
    return table.scan(
        AttributesToGet=scan_attributes,
    )


def modify_scan_results(email_address, scan_results):
    """Modify DynamoDB scan results to remove the provided email address.

    Arguments:
        email_address {string} -- email address to be removed from DynamoDB

        scan_results {dictionary} -- json blob containing the results of the
            target DynamoDB table scan

    Returns:
        dictionary -- json blob with the updated scan results. If an email
        address was flagged for removal it will be denoted with the
        has_updates flag
    """
    for item in scan_results["Items"]:
        try:
            for distro in item["email_distros"]:
                email_distro = item["email_distros"][distro]
                if email_address in email_distro:
                    email_distro.remove(email_address)
                    item["has_updates"] = True
                    log.info("removed %s from %s", email_address, distro)
        except KeyError:
            continue
    return scan_results


def apply_scan_results(updated_scan_results):
    """Apply the updated DynamoDB scan results.

    Arguments:
        updated_scan_results {dictionary} -- Json blob containing
        the updated scan results
    """
    for item in updated_scan_results["Items"]:
        if item.get("has_updates"):
            table.update_item(
                Key={"account_name": item["account_name"]},
                UpdateExpression="set email_distros = :distros",
                ExpressionAttributeValues={":distros": item["email_distros"]},
                ReturnValues="UPDATED_NEW",
            )
            log.info("updated %s", item["account_name"])


def retrieve_s3_object_contents(s3_obj, bucket=os.environ["ARTIFACTS_BUCKET"]):
    """Retrieve S3 object contents."""
    return json.loads(
        s3.get_object(Bucket=bucket, Key=s3_obj)["Body"].read().decode("utf-8")
    )


# this should probably be called recursively for all users in the input list
# otherwise this task will be very 'chatty'
# https://realpython.com/python-thinking-recursively/
def remove_user(email, scan_results):
    """Remove user from scan results."""
    updated_scan_results = modify_scan_results(email, scan_results)
    apply_scan_results(updated_scan_results)


def remove_users_in_list(users):
    """Remove users in list."""
    scan_attributes = ["account_name", "email_distros"]
    scan_results = scan_table(scan_attributes)
    for user in users:
        remove_user(user["email"], scan_results)


def handler(event, context):  # pylint: disable=unused-argument
    """Entrypoint for lambda handler."""
    log.debug("Received event: %s", event)
    if event["action"] == "remove":
        days_since_pwdlastset = os.environ("DAYS_SINCE_PWDLASTSET")
        users = retrieve_s3_object_contents(event["ldap_scan_results"])[
            days_since_pwdlastset
        ]
        remove_users_in_list(users)
        log.info("Successfully removed the stale users from dynamodb")
        return event
    return None
