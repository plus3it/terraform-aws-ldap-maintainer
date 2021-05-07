# SlackBot

terraform-aws-ldap-maintainer slackbot module

## Overview

This module will deploy a Lambda function with an API Gateway endpoint configured for LAMBDA_PROXY. This lambda function provides slash command support to the ldapmaintainer slack integration.

## Supported Slash Commands

*cancel|stop*: Cancels the current execution
*start|run*: Starts a new scan
*help|?*: this help menu

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
| <a name="input_step_function_arn"></a> [step\_function\_arn](#input\_step\_function\_arn) | State machine ARN that the api gateway is able to perform actions against | `string` | n/a | yes |
| <a name="input_target_api_gw_id"></a> [target\_api\_gw\_id](#input\_target\_api\_gw\_id) | ID of the api to add the lambda proxy endpoint to | `string` | n/a | yes |
| <a name="input_target_api_gw_root_resource_id"></a> [target\_api\_gw\_root\_resource\_id](#input\_target\_api\_gw\_root\_resource\_id) | Root resource ID of the api gateway resource to add the lambda proxy endpoint to | `string` | n/a | yes |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Log level of the lambda output, one of: Debug, Info, Warning, Error, or Critical | `string` | `"Info"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"ldap-maintainer"` | no |
| <a name="input_slack_api_token"></a> [slack\_api\_token](#input\_slack\_api\_token) | API token used by the slack client | `string` | `""` | no |
| <a name="input_slack_listener_api_endpoint_arn"></a> [slack\_listener\_api\_endpoint\_arn](#input\_slack\_listener\_api\_endpoint\_arn) | ARN of the slack listener API endpoint | `string` | `""` | no |
| <a name="input_slack_signing_secret"></a> [slack\_signing\_secret](#input\_slack\_signing\_secret) | The slack application's signing secret | `string` | `""` | no |
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
