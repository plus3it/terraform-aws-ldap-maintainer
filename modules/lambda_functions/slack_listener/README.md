# Slack Listener Lambda

Lambda function that responds to slack events from a SQS queue

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| api\_gw\_role\_arn | ARN of the IAM role assigned to the API gateway | string | n/a | yes |
| artifacts\_bucket\_name | Name of the artifacts bucket | string | n/a | yes |
| log\_level | Log level of the lambda output, one of: Debug, Info, Warning, Error, or Critical | string | `"Info"` | no |
| project\_name | Name of the project | string | `"ldap-maintainer"` | no |
| slack\_api\_token | API token used by the slack client | string | n/a | yes |
| slack\_listener\_api\_endpoint\_arn |  | string | `""` | no |
| slack\_signing\_secret | The slack application's signing secret | string | `""` | no |
| step\_function\_arns | List of state machine ARNs that the api gateway is able to perform actions against | list(string) | n/a | yes |
| tags | Map of tags to assign to this module's resources | map(string) | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| function\_arn | The ARN of the Lambda function |
| function\_invoke\_arn | The Invoke ARN of the Lambda function |
| function\_name | The name of the Lambda function |
| function\_qualified\_arn | The qualified ARN of the Lambda function |
| role\_arn | The ARN of the IAM role created for the Lambda function |
| role\_name | The name of the IAM role created for the Lambda function |
| sqs\_queue\_arn |  |
| sqs\_queue\_name |  |

