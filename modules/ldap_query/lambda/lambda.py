"""Python module to perform tasks against a target LDAP database

Requires the credentials of a user with domain admin privileges
"""
import boto3
import collections
import fnmatch
import json
import logging
import os
from datetime import datetime

import ldap
import ldap.asyncsearch
from jinja2 import Environment, FileSystemLoader


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
    log_file_name = "ldap_query.log"

logging.basicConfig(
    filename=log_file_name,
    format="%(asctime)s.%(msecs)03dZ [%(name)s][%(levelname)-5s]: %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%S",
    level=LOG_LEVELS[os.environ.get("LOG_LEVEL", "").lower()],
)
log = logging.getLogger(__name__)

s3 = boto3.client("s3")
ssm = boto3.client("ssm")


class LdapMaintainer:
    def __init__(
        self,
        ldaps_url,
        domain_base,
        svc_user_dn,
        svc_user_pwd,
        days_since_pwdlastset,
        filter_patterns,
        users_to_disable=[],
    ):
        """Initialize"""
        self.ldaps_url = ldaps_url
        self.domain_base = domain_base
        self.svc_user_dn = svc_user_dn
        self.svc_user_pwd = svc_user_pwd
        self.days_since_pwdlastset = int(days_since_pwdlastset)
        self.connection = self.connect()
        self.users_to_disable = users_to_disable
        self.filter_patterns = filter_patterns

    def connect(self):
        """Establish a connection to the LDAP server."""
        log.debug("Attempting to connect to the LDAP server..")
        ldap.set_option(ldap.OPT_X_TLS_REQUIRE_CERT, ldap.OPT_X_TLS_NEVER)
        con = ldap.initialize(self.ldaps_url)
        con.set_option(ldap.OPT_REFERRALS, 0)
        con.bind_s(self.svc_user_dn, self.svc_user_pwd)
        log.debug("Successfully connected to LDAP server.")
        return con

    def search(self, search_root, filter_string=None):
        """Search LDAP using the provided filter string."""
        log.debug("starting search with %s", filter_string)
        ldap_async = ldap.asyncsearch.List(self.connection)
        ldap_async.startSearch(search_root, ldap.SCOPE_SUBTREE, filter_string)
        try:
            partial = ldap_async.processResults()
        except ldap.SIZELIMIT_EXCEEDED:
            log.error("Warning: Server-side size limit exceeded")
        else:
            if partial:
                log.error("Warning: Only partial results received.")

        self.connection.unbind()
        return ldap_async.allResults

    def get_all_users(self):
        """Search LDAP and return all user objects."""
        return self.byte_decode_search_results(
            self.search(
                self.domain_base, "(&(objectCategory=person)(objectClass=user))"
            )
        )

    def get_users(self):
        """
        Returns a list of active users.

        User accounts in the target OU that have been previously disabled
        or configured with passwords that don't expire are ignored.
        """

        non_svc_users = []

        # code reference:
        # https://jackstromberg.com/2013/01/useraccountcontrol-attributeflag-values/

        for user_obj in self.get_all_users():
            try:
                uac = user_obj["user"]["userAccountControl"][0]
                sam_name = user_obj["user"]["sAMAccountName"][0]
                if not self.is_special(sam_name, uac):
                    non_svc_users.append(user_obj["user"])
            except TypeError:
                continue
        # log.debug(f"found users that met filter criteria: {non_svc_users}")
        return non_svc_users

    def disable_users(self):
        con = self.connection
        date = datetime.now().strftime("%Y-%m-%d-T%H%M")
        d = f"***Disabled {date} by ldapmaintbot***"
        for user_obj in self.users_to_disable:
            disable_user = [
                (ldap.MOD_REPLACE, "userAccountControl", [b"514"])
            ]  # https://support.microsoft.com/en-us/help/305144/how-to-use-useraccountcontrol-to-manipulate-user-account-properties
            update_description = [
                (ldap.MOD_REPLACE, "description", [d.encode("utf-8")])
            ]
            con.modify_s(user_obj["dn"], disable_user)
            con.modify_s(user_obj["dn"], update_description)

    def get_days_since_pwdlastset(self, ft):
        # skip users that have never logged in
        if ft == "0":
            return 1
        else:
            pwd_last_set = self.filetime_to_dt(ft)
            today = datetime.now()
            return (today - pwd_last_set).days

    def get_stale_users(self):
        """
        Returns map of users that have not logged on
        since number of days defined in self.days_since_pwdlastset

        example:
        {
            "120": [
                {
                    "name" = "Jane Doe",
                    "email" = "jane.doe@someemail.com",
                    "dn" = ""

                }
            ]
        }
        """
        stale_users = {f"{self.days_since_pwdlastset}": []}
        users = self.get_users()
        for user_obj in users:
            try:
                log.debug("processing user: %s", user_obj)
                ft = user_obj["pwdLastSet"][0]
                desc = user_obj["description"][0]
                days = self.get_days_since_pwdlastset(ft)
                user = {
                    "name": user_obj["cn"][0],
                    "email": user_obj["mail"][0],
                    "dn": user_obj["distinguishedName"][0],
                    "days_since_last_pwd_change": days,
                }
                log.debug("got user: %s", user)
                if days >= self.days_since_pwdlastset or desc == "***TEST***":
                    stale_users[f"{self.days_since_pwdlastset}"].append(user)
            except KeyError:
                continue
        log.debug("retrieved the following stale users: %s", stale_users)
        return stale_users

    def get_ldif(self):
        """Creates a ldif document with the query results"""
        # could be an alternative way of user disablement

    @staticmethod
    def byte_decode_search_results(search_results):
        users = []
        for user in search_results:
            # if the dn is None, skip it.
            if not user[1][0]:
                continue
            else:
                user_obj = {}
                for attribute in user[1][1]:
                    if "ldap://" not in attribute:
                        user[1][1][attribute] = [
                            item.decode(encoding="utf-8", errors="ignore")
                            for item in user[1][1][attribute]
                        ]
                user_obj["dn"] = user[1][0]
                user_obj["user"] = user[1][1]
                users.append(user_obj)
        return users

    def is_special(self, sam_name, uac):
        # list of accounts not to touch
        disabled_codes = [
            "514",  # Disabled Account
            "65536",  # DONT_EXPIRE_PASSWORD
            "66048",  # Enabled, Password Doesn’t Expire
            "66050",  # Disabled, Password Doesn’t Expire
            "66080",  # Disabled, Password Doesn’t Expire & Not Required
            "262658",  # Disabled, Smartcard Required
            "262690",  # Disabled, Smartcard Required, Password Not Required
        ]
        return uac in disabled_codes or fnmatch.filter(self.filter_patterns, sam_name)

    @staticmethod
    def filetime_to_dt(ft):
        """
        Convert windowsfiletime to python datetime.
        ref: https://gist.github.com/Mostafa-Hamdy-Elgiar/9714475f1b3bc224ea063af81566d873  # noqa: E501
        """
        # January 1, 1970 as MS file time
        epoch_as_filetime = 116444736000000000
        hundreds_of_nanoseconds = 10000000
        return datetime.utcfromtimestamp(
            (int(ft) - epoch_as_filetime) / hundreds_of_nanoseconds
        )


def get_file_name(file_name, extension):
    timestamp = datetime.now().strftime("%Y_%m_%d_T%H%M%S.%f")
    return f"{file_name}_{timestamp}.{extension}"


def create_json_doc(**content):
    """create a table"""
    # This can be fleshed out to make the retrieved information
    # more user friendly if desired/required
    artifact = {}
    artifact["content"] = json.dumps(content["users"])
    artifact["file_name"] = get_file_name("user_expiration_table", "json")
    artifact["raw_scan_results"] = True
    return artifact


def get_html_table_headers(**content):
    """
    Return the keys of the first element in the user_list dict.

    We don't care if the dict is unordered b/c the expectation is
    that each element of the dict will be structured the same
    """
    user_list = content["users"]
    days_since_pwdlastset = content["days_since_pwdlastset"]
    try:
        return user_list[days_since_pwdlastset][0].keys()
    except IndexError:
        # return the empty list of there are no accounts to be disabled
        return []


def render_template(template="html_table.html", **kwargs):
    env = Environment(
        loader=FileSystemLoader(
            os.path.join(os.path.dirname(__file__), "templates"), encoding="utf8"
        )
    )
    template = env.get_template(template)
    return template.render(**kwargs)


def create_html_table(**content):
    # un-group the users for the html table
    template_contents = {
        "table_headers": get_html_table_headers(**content),
        "user_list": content["users"],
    }
    artifact = {}
    artifact["content"] = render_template(**template_contents)
    artifact["file_name"] = get_file_name("user_expiration", "html")
    return artifact


def generate_artifacts(**content):
    """Returns the list of objects to upload to s3"""
    artifacts = {}
    artifacts["user_expiration_table"] = create_json_doc(**content)
    artifacts["user_expiration_html"] = create_html_table(**content)
    return artifacts


def put_object(dest_bucket_name, dest_object_name, src_data):
    """
    Add an object to an Amazon S3 bucket
    """
    # Put the object
    s3 = boto3.client("s3")
    # log.debug(f"destination object name: {dest_object_name}")
    s3.put_object(
        Bucket=dest_bucket_name,
        ACL="private",
        ContentEncoding="utf-8",
        Key=dest_object_name,
        Body=src_data,
    )


def create_presigned_url(bucket_name, object_name, expiration=3600):
    s3 = boto3.client("s3")
    return s3.generate_presigned_url(
        "get_object",
        Params={"Bucket": bucket_name, "Key": object_name},
        ExpiresIn=expiration,
    )


def upload_artifact(artifact):
    """Uploads an artifact to s3 and generates a presigned url

    Arguments:
        artifact {dict} -- dictionary containing the artifact's
        contents and file name

    Returns:
        dict -- dictionary containing the object name and presigned url
    """
    bucket_name = os.environ["ARTIFACTS_BUCKET"]
    log.debug("Uploading object: %s to %s", artifact["file_name"], bucket_name)
    put_object(bucket_name, artifact["file_name"], artifact["content"].encode("utf-8"))
    presigned_url = create_presigned_url(bucket_name, artifact["file_name"])
    is_raw_scan_result = False
    if artifact.get("raw_scan_results"):
        is_raw_scan_result = True
    return {
        "file_name": artifact["file_name"],
        "url": presigned_url,
        "raw_scan_results": is_raw_scan_result,
    }


def upload_all_artifacts(**content):
    artifacts = generate_artifacts(**content)
    log.debug("generated artifacts: %s", artifacts)
    response = []
    for artifact in artifacts:
        response.append(upload_artifact(artifacts[artifact]))
    return response


def get_user_counts(users):
    response = {}
    for key in users:
        response[key] = len(users[key])
    return response


def retrieve_s3_object_contents(s3_obj, bucket=os.environ["ARTIFACTS_BUCKET"]):
    return json.loads(
        s3.get_object(Bucket=bucket, Key=s3_obj)["Body"].read().decode("utf-8")
    )


def query_handler(ldap_config, event):
    """Handles query events"""
    ldap_config["users"] = LdapMaintainer(**ldap_config).get_stale_users()
    log.debug("Ldap query results: %s", ldap_config["users"])
    return {
        "query_results": {"totals": get_user_counts(ldap_config["users"])},
        "artifacts": upload_all_artifacts(**ldap_config),
    }


def disable_handler(ldap_config, event):
    """Handles disable events"""
    ldap_config["users_to_disable"] = retrieve_s3_object_contents(
        event["ldap_scan_results"]
    )[ldap_config["days_since_pwdlastset"]]
    log.info("Disabling the following users: %s", ldap_config["users_to_disable"])
    LdapMaintainer(**ldap_config).disable_users()
    log.info("Users successfully disabled")
    return event


def handler(event, context):
    """
    expected event:
    {
        "action": "query" | "disable"
    }
    """
    log.info("Received event: %s", event)
    if event.get("Payload"):
        event = event["Payload"]
    elif event.get("Input"):
        event = event["Input"]

    ssm_key = os.environ["SSM_KEY"]
    svc_user_pwd = ssm.get_parameter(Name=ssm_key, WithDecryption=True)["Parameter"][
        "Value"
    ]

    ldap_config = {
        "ldaps_url": os.environ["LDAPS_URL"],
        "domain_base": os.environ["DOMAIN_BASE"],
        "svc_user_dn": os.environ["SVC_USER_DN"],
        "svc_user_pwd": svc_user_pwd,
        "filter_patterns": json.loads(os.environ["HANDS_OFF_ACCOUNTS"]),
        "days_since_pwdlastset": os.environ["DAYS_SINCE_PWDLASTSET"],
    }

    strategy = {"query": query_handler, "disable": disable_handler}

    return strategy[event["action"]](ldap_config, event)
