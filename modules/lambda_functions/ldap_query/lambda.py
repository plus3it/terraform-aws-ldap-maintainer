"""Python module to perform tasks against a target LDAP database

Requires the credentials of a user with domain admin privileges
"""
import boto3
import collections
import json
import logging
import os
from datetime import datetime

import ldap
import ldap.asyncsearch


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
    log_file_name = 'ldap_maintainer.log'

logging.basicConfig(
    filename=log_file_name,
    format='%(asctime)s.%(msecs)03dZ [%(name)s][%(levelname)-5s]: %(message)s',
    datefmt='%Y-%m-%dT%H:%M:%S',
    level=LOG_LEVELS[os.environ.get('LOG_LEVEL', '').lower()])
log = logging.getLogger(__name__)


LDAPS_URL = os.environ['LDAPS_URL']
DOMAIN_BASE = os.environ['DOMAIN_BASE']
SSM_KEY = os.environ['SSM_KEY']
SVC_USER_DN = os.environ['SVC_USER_DN']

s3 = boto3.client('s3')
ssm = boto3.client('ssm')

SVC_USER_PWD = ssm.get_parameter(
    Name=SSM_KEY,
    WithDecryption=True
)['Parameter']['Value']


class LdapMaintainer:

    def __init__(self):
        """Initialize"""
        self.connection = self.connect()

    def filetime_to_dt(self, ft):
        """
        Convert windowsfiletime to python datetime.
        ref: https://gist.github.com/Mostafa-Hamdy-Elgiar/9714475f1b3bc224ea063af81566d873  # noqa: E501
        """
        # January 1, 1970 as MS file time
        epoch_as_filetime = 116444736000000000
        hundreds_of_nanoseconds = 10000000
        return datetime.utcfromtimestamp(
            (int(ft) - epoch_as_filetime) / hundreds_of_nanoseconds)

    def connect(self):
        """Establish a connection to the LDAP server."""
        log.debug("Attempting to connect to the LDAP server..")
        try:
            ldap.set_option(ldap.OPT_X_TLS_REQUIRE_CERT, ldap.OPT_X_TLS_NEVER)
            con = ldap.initialize(LDAPS_URL)
            con.set_option(ldap.OPT_REFERRALS, 0)
            con.bind_s(SVC_USER_DN, SVC_USER_PWD)
            log.debug("Successfully connected to LDAP server.")
            return con
        except ldap.LDAPError:
            log.error("Failed to connect to the LDAP server.")

    def search(self, filter_string=None):
        """Search LDAP using the provided filter string."""
        log.debug("starting search with {}".format(filter_string))
        ldap_async = ldap.asyncsearch.List(self.connection)
        search_root = DOMAIN_BASE
        ldap_async.startSearch(
            search_root,
            ldap.SCOPE_SUBTREE,
            filter_string
        )
        try:
            partial = ldap_async.processResults()
        except ldap_async.SIZELIMIT_EXCEEDED:
            log.error("Warning: Server-side size limit exceeded")
        else:
            if partial:
                log.error("Warning: Only partial results received.")

        self.connection.unbind()
        return ldap_async.allResults

    @staticmethod
    def byte_decode_search_results(search_results):
        users = []
        for user in search_results:
            user_obj = {}
            for attribute in user[1][1]:
                try:
                    attribute_list = user[1][1][attribute]
                    for i in range(len(attribute_list)):
                        try:
                            attribute_list[i] = (
                                attribute_list[i].decode('utf-8'))
                        except UnicodeDecodeError:
                            # ignore the user's GUID and SID
                            attribute_list[i] = "ignored"
                            continue
                except TypeError:
                    # some elements are already strings
                    # so just continue past them
                    continue
            user_obj['dn'] = user[1][0]
            user_obj['user'] = user[1][1]
            users.append(user_obj)
        return users

    def get_all_users(self):
        """Search LDAP and return all user objects."""
        return self.byte_decode_search_results(
            self.search("(&(objectCategory=person)(objectClass=user))"))

    def get_users(self):
        """
        Returns a list of active users.

        User accounts in the target OU that have been previously disabled
        or configured with passwords that don't expire are ignored.
        """

        non_svc_users = []

        # code reference:
        # https://jackstromberg.com/2013/01/useraccountcontrol-attributeflag-values/
        disabled_codes = [
            "514",     # Disabled Account
            "65536",   # DONT_EXPIRE_PASSWORD
            "66048",   # Enabled, Password Doesn’t Expire
            "66050",   # Disabled, Password Doesn’t Expire
            "66080",   # Disabled, Password Doesn’t Expire & Not Required
            "262658",  # Disabled, Smartcard Required
            "262690"   # Disabled, Smartcard Required, Password Not Required
        ]
        # list of three letter prefixes to filter out of results
        filter_prefixes = json.loads(os.environ['FILTER_PREFIXES'])
        # list of accounts not to touch
        hands_off = json.loads(os.environ['HANDS_OFF_ACCOUNTS'])
        for user_obj in self.get_all_users():
            try:
                uac = user_obj['user']['userAccountControl'][0]
                sam_name = user_obj['user']['sAMAccountName'][0]
                if (
                    uac not in disabled_codes and
                    sam_name[:3] not in filter_prefixes and
                    sam_name not in hands_off
                ):
                    non_svc_users.append(user_obj['user'])
            except TypeError:
                continue
        # log.debug(f"found users that met filter criteria: {non_svc_users}")
        return non_svc_users

    def disable_users(self, user_list):
        con = self.connect()
        date = datetime.now().strftime("%Y-%m-%d-T%H%M")
        d = f"***Disabled {date} by ldapmaintbot***"
        for user_obj in user_list:
            disable_user = [(
                ldap.MOD_REPLACE,
                'userAccountControl',
                [b'514'])]  # https://support.microsoft.com/en-us/help/305144/how-to-use-useraccountcontrol-to-manipulate-user-account-properties
            update_description = [(
                ldap.MOD_REPLACE,
                'description',
                [d.encode('utf-8')])]
            con.modify_s(user_obj['dn'], disable_user)
            con.modify_s(user_obj['dn'], update_description)

    def get_stale_users(self):
        """
        Returns map of users that have not logged on
        in 120, 90, and 60 day increments

        example:
        {
            "120": [
                {
                    "name" = "Jane Doe",
                    "email" = "jane.doe@someemail.com",
                    "dn" = ""

                }
            ]
            "90": [userobj0, userobj1, etc..]
            "60": [userobj0, userobj1, etc..]
            "never": [userobj0, userobj1, etc..]
        }
        """
        stale_users = {
            "120": [],
            "90": [],
            "60": [],
            "never": []
        }
        today = datetime.now()
        users = self.get_users()
        for user_obj in users:
            try:
                log.debug(f'processing user: {user_obj}')
                ft = user_obj['pwdLastSet'][0]
                desc = user_obj['description'][0]
                pwd_last_set = self.filetime_to_dt(ft)
                days = (today - pwd_last_set).days
                user = {
                    "name": user_obj['cn'][0],
                    "email": user_obj['mail'][0],
                    "dn": user_obj['distinguishedName'][0],
                    "days_since_last_pwd_change": days
                }
                log.debug(f'got user: {user}')
                # if employeeType is set to DTU assume the user is a test user
                if days >= 120 or desc == "Test account":
                    stale_users["120"].append(user)
                elif days >= 90:
                    stale_users["90"].append(user)
                elif days >= 60:
                    stale_users["60"].append(user)
            except KeyError:
                continue
        # log.debug(f"retrieved the following stale users: {stale_users}")
        return stale_users

    def get_ldif(self):
        """Creates a ldif document with the query results"""
        # could be an alternative way of user disablement


def create_table(content):
    """create a table"""
    # This can be fleshed out to make the retrieved information
    # more user friendly if desired/required
    return json.dumps(content)


def generate_artifacts(content):
    """Returns the list of objects to upload to s3"""
    artifacts = {}
    artifacts['user_expiration_table'] = create_table(content)
    # artifacts.append(LdapMaintainer().get_ldif())
    return artifacts


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


def create_presigned_url(bucket_name, object_name, expiration=3600):
    s3 = boto3.client('s3')
    try:
        response = s3.generate_presigned_url(
            'get_object',
            Params={
                'Bucket': bucket_name,
                'Key': object_name
                },
            ExpiresIn=expiration
        )
    except s3.exceptions.ClientError as e:
        log.error(e)
        return None
    # The response contains the presigned URL
    return response


def upload_artifacts(content):
    presigned_urls = {}
    artifacts = generate_artifacts(content)
    log.debug(f"generated artifacts: {artifacts}")
    bucket_name = os.environ['ARTIFACTS_BUCKET']
    timestamp = datetime.now().strftime("%Y-%m-%d-T%H%M%S.%f")
    for key in artifacts:
        object_name = f"{key}-{timestamp}.json"
        log.debug(f'Uploading object: {object_name} to {bucket_name}')
        if put_object(
                bucket_name,
                object_name,
                artifacts[key].encode("utf-8")):
            presigned_urls[key] = create_presigned_url(
                bucket_name, object_name)
        else:
            log.error('Encountered error when uploading artifact')
    return presigned_urls


def get_user_counts(users):
    response = {}
    for key in users:
        response[key] = len(users[key])
    return response


def get_last_modified():
    return lambda obj: int(obj['LastModified'].strftime('%s'))


def get_latest_s3_object(
    bucket=os.environ['ARTIFACTS_BUCKET'],
    prefix='user_expiration_table'
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
        Key=s3_obj['Key']
        )['Body'].read().decode('utf-8'))


def get_previous_scan_results():
    s3_obj = get_latest_s3_object()
    return retrieve_s3_object_contents(s3_obj)


def handler(event, context):
    """
    expected event:
    {
        "action": query | disable
    }
    """
    log.debug(f'Received event: {event}')
    if event.get('Input'):
        event = event['Input']
    if event.get("action"):
        if event['action'] == "query":
            users = LdapMaintainer().get_stale_users()
            log.debug(f"Ldap query results: {users}")
            return {
                "query_results": {
                    "totals": get_user_counts(users)
                },
                "artifact_urls": upload_artifacts(users),
                }
        elif event['action'] == "disable":
            users = get_previous_scan_results()['120']
            log.info(f"Disabling the following users: {users}")
            LdapMaintainer().disable_users(users)
            log.info("Users successfully disabled")
