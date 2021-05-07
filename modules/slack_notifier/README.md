# Slack Notifier Lambda

Lambda that updates slack and a target step function

## Overview

This function's sole purpose is to format the results of the [LDAP Query](/modules/lambda_functions/ldap_query) function combined with this project's step function [task token](https://docs.aws.amazon.com/step-functions/latest/dg/connect-to-resource.html#connect-wait-token) into an actionable message.

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
| [aws_iam_policy_document.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_s3_bucket.artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_artifacts_bucket_name"></a> [artifacts\_bucket\_name](#input\_artifacts\_bucket\_name) | Name of the artifacts bucket | `string` | n/a | yes |
| <a name="input_invoke_base_url"></a> [invoke\_base\_url](#input\_invoke\_base\_url) | Base URL of the api gateway endpoint to pass to slack for approve/deny actions | `string` | n/a | yes |
| <a name="input_sfn_activity_arn"></a> [sfn\_activity\_arn](#input\_sfn\_activity\_arn) | ARN of the state machine activity to query for a taskToken | `string` | n/a | yes |
| <a name="input_slack_api_token"></a> [slack\_api\_token](#input\_slack\_api\_token) | API token used by the slack client | `string` | n/a | yes |
| <a name="input_slack_channel_id"></a> [slack\_channel\_id](#input\_slack\_channel\_id) | Channel that the slack notifier will post to | `string` | n/a | yes |
| <a name="input_days_since_pwdlastset"></a> [days\_since\_pwdlastset](#input\_days\_since\_pwdlastset) | Number of days since the pwdLastSet ldap attribute has been updated. This metric is used to disable the target ldap object. | `number` | `120` | no |
| <a name="input_filter_prefixes"></a> [filter\_prefixes](#input\_filter\_prefixes) | (Optional) List of three letter user name prefixes to filter out of the user search results | `list(string)` | `[]` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | (Optional) Log level of the lambda output, one of: Debug, Info, Warning, Error, or Critical | `string` | `"Info"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"ldap-maintainer"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to this module's resources | `map(string)` | `{}` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | (Optional)Timezone that the slack notifications will be timestamped with | `string` | `"US/Eastern"` | no |

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
