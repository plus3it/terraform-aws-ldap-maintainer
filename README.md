# terraform-aws-ldap-maintainer

A step function to maintain LDAP users via slack.

## Overview

This project deploys a collection of lambda functions, an api gateway endpoint, and a step function implemented with the [callback pattern](https://docs.aws.amazon.com/step-functions/latest/dg/connect-to-resource.html#connect-wait-token) that will automate disabling LDAP users via an interactive slack message.

## Architecture

![State Machine Definition](_docs/state_machine_def_0.0.1.png)

## Submodules

- [API Gateway](/modules/api_gateway): An API endpoint that responds asynchronously to slack events and triggers the Slack Listener lambda function
- [LDAP Query](/modules/ldap_query): Lambda function used to perform actions against a target ldap database
- [Slack Listener](/modules/slack_listener): Lambda function that responds to slack events via an asynchronously executed lambda function
- [Slack Notifier](/modules/slack_notifier): Lambda function that sends status updates to slack and a target step function
- [Slack Bot](/modules/slack_bot): API Gateway endpoint and Lambda function that responds to slash commands from slack

## Setup

1. Retrieve the LDAPS endpoint of your target AD deployment.

    **Note:** This can be accomplished via SimpleAD by creating an ALB that listens via TLS on port 636 and forwards requests to your SimpleAD A record. See the associated [AWS blog post](https://aws.amazon.com/blogs/security/how-to-configure-an-ldaps-endpoint-for-simple-ad/) or the tests of this project for a reference architecture.

2. Within your LDAP directory create a user that will be used by the lambda function. This user will need permissions to query LDAP and disable users.

    **Note:** Refer to the following article to scope this permission to a single user: [Delegate the Enable/Disable Accounts Permission in Active Directory](https://thebackroomtech.com/2009/07/01/howto-delegate-the-enabledisable-accounts-permission-in-active-directory/)

3. Populate an *encrypted* ssm parameter with this new user's password and use the key value as the input for `svc_user_pwd_ssm_key` variable.
4. Register a new slack application at https://api.slack.com and capture the "Slack Signing Secret" from the "Basic Information" section of the app's Settings

    **Note:** For each instance of this module, you will almost certainly need
    a new Slack app. This is because the API Gateway endpoints must be configured
    within the Slack app's settings, and only a single Interactivity Request URL
    can be specified per Slack app. Each instance of this module will have a different
    Interactivity Request URL.

5. Grant Scopes to the app, and capture the OAuth Token:
      1. Navigate to Features > OAuth & Permissions
      2. Under Scopes, select `command`
      3. Select "Install app" to your workspace
      4. Save off the "Bot User OAuth Token" and use it and the "Slack Signing Secret" in the next step
6. Configure your `terraform.tfvars` with the required inputs.
7. Run `terraform init/apply`
8. Enable Interactivity and a Slash Command your slack integration:
      1. Go to https://api.slack.com
      2. Find your app
      3. Navigate to Features > Interactivity & Shortcuts > Interactivity
      4. Enter the output value `slack_event_listener_endpoint` from the terraform apply for the Request URL
      5. Navigate to Features > Slash Commands
      6. Create a new command called `/ldap`
      7. Use the output value `slack_bot_listener_endpoint` for the Request URL
9. Test the integration from slack by calling `/ldap run` or manually by triggering the LDAP maintenance step function with the following payload: `{"action": "query" }`

## References

- The [AD Schema](https://docs.microsoft.com/en-us/windows/win32/adschema/active-directory-schema)
- Bobbie Couhbor's awesome [blogpost](https://blog.kloud.com.au/2018/01/09/replacing-the-service-desk-with-bots-using-amazon-lex-and-amazon-connect-part-3/) on using python-ldap via lambda
- Rigel Di Scala's blog post [Write a serverless Slack chat bot using AWS](https://chatbotslife.com/write-a-serverless-slack-chat-bot-using-aws-e2d2432c380e)

<!-- BEGIN TFDOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy_document.cwe](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cwe_trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sfn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_base_dn"></a> [domain\_base\_dn](#input\_domain\_base\_dn) | Distinguished name of the domain | `string` | n/a | yes |
| <a name="input_dynamodb_table_arn"></a> [dynamodb\_table\_arn](#input\_dynamodb\_table\_arn) | ARN of the dynamodb to take actions against | `string` | n/a | yes |
| <a name="input_dynamodb_table_name"></a> [dynamodb\_table\_name](#input\_dynamodb\_table\_name) | Name of the dynamodb to take actions against | `string` | n/a | yes |
| <a name="input_ldaps_url"></a> [ldaps\_url](#input\_ldaps\_url) | LDAPS URL of the target domain | `string` | n/a | yes |
| <a name="input_slack_api_token"></a> [slack\_api\_token](#input\_slack\_api\_token) | API token used by the slack client. Located under the slack application Settings > Install App > Bot User OAuth Access Token | `string` | n/a | yes |
| <a name="input_slack_channel_id"></a> [slack\_channel\_id](#input\_slack\_channel\_id) | Channel that the slack notifier will post to | `string` | n/a | yes |
| <a name="input_slack_signing_secret"></a> [slack\_signing\_secret](#input\_slack\_signing\_secret) | The slack application's signing secret. Located under the slack application Settings > Basic Information | `string` | n/a | yes |
| <a name="input_svc_user_dn"></a> [svc\_user\_dn](#input\_svc\_user\_dn) | Distinguished name of the LDAP Maintenance service account used to manage simpleAD | `string` | n/a | yes |
| <a name="input_svc_user_pwd_ssm_key"></a> [svc\_user\_pwd\_ssm\_key](#input\_svc\_user\_pwd\_ssm\_key) | SSM parameter key that contains the LDAP Maintenance service account password | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC hosting the target Simple AD instance | `string` | n/a | yes |
| <a name="input_additional_cleanup_tasks"></a> [additional\_cleanup\_tasks](#input\_additional\_cleanup\_tasks) | (Optional) List of step function tasks to execute in parallel once the cleanup action has been approved. | `string` | `""` | no |
| <a name="input_days_since_pwdlastset"></a> [days\_since\_pwdlastset](#input\_days\_since\_pwdlastset) | Number of days since the pwdLastSet ldap attribute has been updated. This metric is used to disable the target ldap object. | `number` | `120` | no |
| <a name="input_enable_dynamodb_cleanup"></a> [enable\_dynamodb\_cleanup](#input\_enable\_dynamodb\_cleanup) | Controls wether to enable the dynamodb cleanup resources. The lambda function and supporting resources will still be deployed. | `bool` | `true` | no |
| <a name="input_hands_off_accounts"></a> [hands\_off\_accounts](#input\_hands\_off\_accounts) | (Optional) List of user names to filter out of the user search results | `list(string)` | `[]` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | (Optional) Log level of the lambda output, one of: Debug, Info, Warning, Error, or Critical | `string` | `"Info"` | no |
| <a name="input_maintenance_schedule"></a> [maintenance\_schedule](#input\_maintenance\_schedule) | Periodicity at which to trigger the ldap maintenance step function | `string` | `"cron(0 8 1 * ? *)"` | no |
| <a name="input_manual_approval_timeout"></a> [manual\_approval\_timeout](#input\_manual\_approval\_timeout) | Timeout in seconds for the manual approval step. | `number` | `3600` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"ldap-maintainer"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to this module's resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_python_ldap_layer_arn"></a> [python\_ldap\_layer\_arn](#output\_python\_ldap\_layer\_arn) | ARN of the python-ldap layer |
| <a name="output_slack_bot_listener_endpoint"></a> [slack\_bot\_listener\_endpoint](#output\_slack\_bot\_listener\_endpoint) | Endpoint to use for the slack app's Slash Command Request URL |
| <a name="output_slack_event_listener_endpoint"></a> [slack\_event\_listener\_endpoint](#output\_slack\_event\_listener\_endpoint) | Endpoint to use for the slack app's Interactivity Request URL |

<!-- END TFDOCS -->
