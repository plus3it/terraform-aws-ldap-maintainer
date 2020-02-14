# SlackBot

terraform-aws-ldap-maintainer slackbot module

## Overview

This module will deploy a Lambda function with an API Gateway endpoint configured for LAMBDA_PROXY. This lambda function provides slash command support to the ldapmaintainer slack integration.

## Supported Slash Commands

*cancel|stop*: Cancels the current execution
*start|run*: Starts a new scan
*help|?*: this help menu

<!-- BEGIN TFDOCS -->
## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| artifacts\_bucket\_name | Name of the artifacts bucket | `string` | n/a | yes |
| step\_function\_arn | State machine ARN that the api gateway is able to perform actions against | `string` | n/a | yes |
| target\_api\_gw | Name of the api to add the lambda proxy to | `string` | n/a | yes |
| log\_level | Log level of the lambda output, one of: Debug, Info, Warning, Error, or Critical | `string` | `"Info"` | no |
| project\_name | Name of the project | `string` | `"ldap-maintainer"` | no |
| slack\_api\_token | API token used by the slack client | `string` | `""` | no |
| slack\_listener\_api\_endpoint\_arn | ARN of the slack listener API endpoint | `string` | `""` | no |
| slack\_signing\_secret | The slack application's signing secret | `string` | `""` | no |
| tags | Map of tags to assign to this module's resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| function\_arn | The ARN of the Lambda function |
| function\_invoke\_arn | The Invoke ARN of the Lambda function |
| function\_name | The name of the Lambda function |
| function\_qualified\_arn | The qualified ARN of the Lambda function |
| role\_arn | The ARN of the IAM role created for the Lambda function |
| role\_name | The name of the IAM role created for the Lambda function |

<!-- END TFDOCS -->
