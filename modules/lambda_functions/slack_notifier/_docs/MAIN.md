# Slack Notifier Lambda

Lambda that updates slack and a target step function

## Overview

This function's sole purpose is to format the results of the [LDAP Query](/modules/lambda_functions/ldap_query) function combined with this project's step function [task token](https://docs.aws.amazon.com/step-functions/latest/dg/connect-to-resource.html#connect-wait-token) into an actionable message.
