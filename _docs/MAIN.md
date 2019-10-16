<<<<<<< HEAD
# terraform-aws-ldap-maintainer

A step function to maintain LDAP users via slack.
=======
# terraform-aws-ldap-maintenance

A step function to maintain LDAP users via slack.

## Overview

This project deploys a collection of lambda functions, an api endpoint, and a step function that will automate disabling LDAP users via an interactive slack message.

## Setup

1. Retrieve the LDAPS endpoint of your target AD deployment.

    **Note:** This can be accomplished via SimpleAD by creating an ALB that listens via TLS on port 636 and forwards requests to your SimpleAD A record. See the associated [AWS blog post](https://aws.amazon.com/blogs/security/how-to-configure-an-ldaps-endpoint-for-simple-ad/) or the tests of this project for a reference architecture.

2. Within your LDAP directory create a user that will be used by the lambda function. This user will need permissions to query LDAP and disable users.
3. Populate an *encrypted* ssm parameter with this new user's password and use the key value as the input for `svc_user_pwd_ssm_key` variable.
4. Generate the lambda layers for this project by running `bin/generate-layers.sh` use the `-r` option to generate the layers via docker or `-c` to create them locally.
5. Configure your `terraform.tfvars` with the required inputs.
6. Run `terraform init/apply`
7. Using the provided output url, enable slack events for your slackbot
      1. Go to https://api.slack.com
      2. Find your app
      3. Navigate to Features > Event Subscriptions > Enable Events
      4. Enter the api gateway url created in the previous step
8. Test the integration by manually triggering the LDAP maintenance step function with the following payload: `{"action": "query" }`

## Submodules

[API Gateway](/modules/api_gateway)

### Lambda Functions

- [DynamoDB Cleanup](/modules/lambda_functions/dynamodb_cleanup): Facilitates removing disabled users' email(s) from a target dynamoDB table
- [LDAP Query](/modules/lambda_functions/ldap_query): Used to perform actions against a target ldap database
- [Slack Listener](/modules/lambda_functions/slack_listener): Responds to slack events from a SQS queue
- [Slack Notifier](/modules/lambda_functions/slack_notifier): Sends status updates to slack and a target step function

## Architecture

![State Machine Definition](_docs/state_machine_def_0.0.1.png)

## References

- The [AD Schema](https://docs.microsoft.com/en-us/windows/win32/adschema/active-directory-schema)
- Bobbie Couhbor's awesome [blogpost](https://blog.kloud.com.au/2018/01/09/replacing-the-service-desk-with-bots-using-amazon-lex-and-amazon-connect-part-3/) on using python-ldap via lambda
- Rigel Di Scala's blog post [Write a serverless Slack chat bot using AWS](https://chatbotslife.com/write-a-serverless-slack-chat-bot-using-aws-e2d2432c380e)
>>>>>>> 2fab932... Module initialization
