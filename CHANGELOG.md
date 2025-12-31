## terraform-aws-ldap-maintainer Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

### 0.1.0

**Released**: 2025.12.30

**Commit Delta**: [Change from 0.0.6 release](https://github.com/plus3it/terraform-aws-ldap-maintainer/compare/0.0.6...0.1.0)

**Summary**:

*   Addresses deprecation warning for aws_region "name" attribute

### 0.0.6

**Released**: 2021.03.31

**Commit Delta**: [Change from 0.0.5 release](https://github.com/plus3it/terraform-aws-ldap-maintainer/compare/0.0.5...0.0.6)

**Summary**:

*   An error in run_ldap_query_again will now update the message in slack to say
    indicate an error occurred. Also, the step function will be marked as failed
*   The step wait_for_manual_approval will timeout if no reply is received within
    the number of seconds set by the variable manual_approval_timeout (3600 seconds
    by default)
*   Clarifies instructions in README for setting up the slack app

### 0.0.5

**Commit Delta**: N/A

**Released**: 2019.11.1

**Summary**:

*   Initial release!
