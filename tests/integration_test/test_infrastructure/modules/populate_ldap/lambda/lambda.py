# pylint: skip-file
import collections
import fnmatch
import json
import logging
import os
import random
from datetime import datetime
from time import sleep

import ldap
import ldap.asyncsearch
import ldap.modlist


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
    log_file_name = "ldap_maintainer.log"

logging.basicConfig(
    filename=log_file_name,
    format="%(asctime)s.%(msecs)03dZ [%(name)s][%(levelname)-5s]: %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%S",
    level=LOG_LEVELS[os.environ.get("LOG_LEVEL", "").lower()],
)
log = logging.getLogger(__name__)


LDAPS_URL = os.environ["LDAPS_URL"]
DOMAIN_BASE = os.environ["DOMAIN_BASE"]
SVC_USER_DN = os.environ["SVC_USER_DN"]
SVC_USER_PWD = os.environ["SVC_USER_PWD"]


class LdapMaintainer:
    def __init__(self):
        self.connection = self.connect()

    def connect(self):
        """Establish a connection to the LDAP server."""
        log.debug("Attempting to connect to the LDAP server..")
        ldap.set_option(ldap.OPT_X_TLS_REQUIRE_CERT, ldap.OPT_X_TLS_NEVER)
        con = ldap.initialize(LDAPS_URL)
        con.set_option(ldap.OPT_REFERRALS, 0)
        con.bind_s(SVC_USER_DN, SVC_USER_PWD)
        log.debug("Successfully connected to LDAP server.")
        return con

    def add_users(self, user_list):
        con = self.connect()
        user_count = 0
        log.info("Received input list of %s users", len(user_list))
        for user_obj in user_list:
            try:
                con.add_s(user_obj["dn"], ldap.modlist.addModlist(user_obj["user"]))
                user_count += 1
            except ldap.ALREADY_EXISTS:
                continue
        log.info("Created %s users", user_count)

    @staticmethod
    def ldap_retry(func, max_tries=4, sleep_time=2):
        """ldap retry function with back off timer
        https://stackoverflow.com/a/33792744/12031185

        Arguments:
            func {function} -- [input python-ldap function]

        Keyword Arguments:
            max_tries {int} -- [number of retries] (default: {4})
            sleep_time {int} -- [(sec)time to next execution] (default: {2})

        Returns:
            [varies] -- [returns the results of the python-ldap function call]
        """
        for _ in range(0, max_tries):
            try:
                return func()
            except ldap.NO_SUCH_OBJECT:
                sleep(sleep_time)
                sleep_time *= 2

    @staticmethod
    def get_random_users(user_list, user_count):
        return random.sample(user_list, min(len(user_list), user_count))

    def disable_random_users(self, user_list, user_count):
        con = self.connect()
        date = datetime.now().strftime("%Y-%m-%d-T%H%M")
        d = f"***Disabled {date} by ldapmaintbot***"
        # get a random list of users and disable them
        random_list = self.get_random_users(user_list, user_count)
        for user_obj in random_list:
            disable_user = [(ldap.MOD_REPLACE, "userAccountControl", [b"66050"])]
            update_description = [
                (ldap.MOD_REPLACE, "description", [d.encode("utf-8")])
            ]
            self.ldap_retry(lambda: con.modify_s(user_obj["dn"], disable_user))
            self.ldap_retry(lambda: con.modify_s(user_obj["dn"], update_description))

    def label_random_users(self, user_list, user_count):
        con = self.connect()
        d = "***TEST***"
        random_list = self.get_random_users(user_list, user_count)
        for user_obj in random_list:
            update_description = [
                (ldap.MOD_REPLACE, "description", [d.encode("utf-8")])
            ]
            self.ldap_retry(lambda: con.modify_s(user_obj["dn"], update_description))


def byte_encode_user_map(input_map):
    """
    Performs byte encode operations on LDAP user objects
    """
    for element in input_map:
        element_list = input_map[element]
        for i in range(len(element_list)):
            element_list[i] = element_list[i].encode("utf-8")
    return input_map


def generate_user_objects(test_users):
    user_list = []
    for user in test_users:
        user_obj = {}
        full_name = f"{user['name']}{user['surname']}".lower()
        user_obj["dn"] = f"cn={full_name},CN=Users,{DOMAIN_BASE}"
        user_obj["user"] = byte_encode_user_map(
            {
                "cn": [full_name],
                "displayName": [f"Test account {full_name}"],
                "description": ["Test account"],
                "givenName": [full_name],
                "lastLogoff": ["0"],
                "lastLogon": ["0"],
                "logonCount": ["0"],
                "mail": [f"{full_name}@email.com"],
                "name": [f"TEST {full_name}"],
                "objectClass": ["top", "person", "organizationalPerson", "user"],
                "sAMAccountName": [user["sam"]],
                # Normal Account, require user to change pwd on next login
                "userAccountControl": ["512"],
            }
        )
        user_list.append(user_obj)
    return user_list


def load_json_file(file_name):
    with open(file_name) as w:
        return json.loads(w.read())


def handler(event, context):
    test_users = load_json_file("usernames.json")

    # distinguish between standard and special users
    # to avoid randomly disabling them
    standard_users = generate_user_objects(test_users["standard"])
    special_users = generate_user_objects(test_users["special"])
    all_users = standard_users + special_users
    # create the users in the test LDAP deployment
    ldap_maint = LdapMaintainer()
    ldap_maint.add_users(all_users)
    # disable 5 random users
    ldap_maint.disable_random_users(standard_users, 5)
    # label a random 20 users for processing by the ldap maintainer lambda
    ldap_maint.label_random_users(standard_users, 20)
