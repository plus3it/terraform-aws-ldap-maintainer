# DynamoDB Cleanup Lambda

Lambda function to facilitate removing disabled users' email(s) from a target dynamoDB table

<!-- BEGIN TFDOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy_document.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.placeholder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_s3_bucket.artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_artifacts_bucket_name"></a> [artifacts\_bucket\_name](#input\_artifacts\_bucket\_name) | Name of the artifacts bucket | `string` | n/a | yes |
| <a name="input_dynamodb_table_arn"></a> [dynamodb\_table\_arn](#input\_dynamodb\_table\_arn) | ARN of the dynamodb table to perform maintenance actions against | `string` | n/a | yes |
| <a name="input_dynamodb_table_name"></a> [dynamodb\_table\_name](#input\_dynamodb\_table\_name) | Name of the dynamodb to take actions against | `string` | n/a | yes |
| <a name="input_days_since_pwdlastset"></a> [days\_since\_pwdlastset](#input\_days\_since\_pwdlastset) | Number of days since the pwdLastSet ldap attribute has been updated. This metric is used to disable the target ldap object. | `number` | `120` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | (Optional) Log level of the lambda output, one of: Debug, Info, Warning, Error, or Critical | `string` | `"Info"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"ldap-maintainer"` | no |
| <a name="input_resource_name_suffix"></a> [resource\_name\_suffix](#input\_resource\_name\_suffix) | Suffix to append this module's resource names | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to this module's resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | The ARN of the Lambda function |
| <a name="output_function_invoke_arn"></a> [function\_invoke\_arn](#output\_function\_invoke\_arn) | The Invoke ARN of the Lambda function |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | The name of the Lambda function |
| <a name="output_function_qualified_arn"></a> [function\_qualified\_arn](#output\_function\_qualified\_arn) | The qualified ARN of the Lambda function |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The ARN of the IAM role created for the Lambda function |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | The name of the IAM role created for the Lambda function |

<!-- END TFDOCS -->
