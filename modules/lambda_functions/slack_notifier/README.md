# Slack Notifier Lambda

Lambda that updates slack and a target step function

## Overview

This function's sole purpose is to format the results of the [LDAP Query](/modules/lambda_functions/ldap_query) function combined with this project's step function [task token](https://docs.aws.amazon.com/step-functions/latest/dg/connect-to-resource.html#connect-wait-token) into an actionable message.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| artifacts\_bucket\_name | Name of the artifacts bucket | string | n/a | yes |
| filter\_prefixes | (Optional) List of three letter user name prefixes to filter out of the user search results | list(string) | `<list>` | no |
| invoke\_base\_url | Base URL of the api gateway endpoint to pass to slack for approve/deny actions | string | n/a | yes |
| log\_level | (Optional) Log level of the lambda output, one of: Debug, Info, Warning, Error, or Critical | string | `"Info"` | no |
| project\_name | Name of the project | string | `"ldap-maintainer"` | no |
| sfn\_activity\_arn | ARN of the state machine activity to query for a taskToken | string | n/a | yes |
| slack\_api\_token | API token used by the slack client | string | n/a | yes |
| slack\_channel\_id | Channel that the slack notifier will post to | string | n/a | yes |
| tags | Map of tags to assign to this module's resources | map(string) | `<map>` | no |
| timezone | (Optional)Timezone that the slack notifications will be timestamped with | string | `"US/Eastern"` | no |

## Outputs

| Name | Description |
|------|-------------|
| function\_arn | The ARN of the Lambda function |
| function\_invoke\_arn | The Invoke ARN of the Lambda function |
| function\_name | The name of the Lambda function |
| function\_qualified\_arn | The qualified ARN of the Lambda function |
| role\_arn | The ARN of the IAM role created for the Lambda function |
| role\_name | The name of the IAM role created for the Lambda function |

