# API Gateway

terraform-aws-ldap-maintainer API Gateway module

## Overview

This module will deploy an API endpoint with invoke permissions to a target lambda function. This lambda function will then be executed asynchronously when the endpoint is triggered. Currently this endpoint has only been configured to respond to slack events.
