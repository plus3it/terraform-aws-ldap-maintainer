# DynamoDB Cleanup Lambda

Lambda function to facilitate removing disabled users' email(s) from a target dynamoDB table

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| artifacts\_bucket\_name | Name of the artifacts bucket | string | n/a | yes |
| dynamodb\_table\_arn | ARN of the dynamodb table to perform maintenance actions against | string | n/a | yes |
| dynamodb\_table\_name | Name of the dynamodb to take actions against | string | n/a | yes |
| log\_level | (Optional) Log level of the lambda output, one of: Debug, Info, Warning, Error, or Critical | string | `"Info"` | no |
| project\_name | Name of the project | string | `"ldap-maintainer"` | no |
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

