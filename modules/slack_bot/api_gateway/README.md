# API Gateway

terraform-aws-ldap-maintainer API Gateway module

## Overview

This module will deploy an API endpoint that proxies requests for the slackbot Lambda function.

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
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.api_gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_passthrough_lambda"></a> [passthrough\_lambda](#input\_passthrough\_lambda) | Object of attributes for the lambda function that API gateway will pass information to | <pre>object({<br>    function_arn        = string<br>    function_invoke_arn = string<br>    function_name       = string<br>  })</pre> | n/a | yes |
| <a name="input_target_api_gw_id"></a> [target\_api\_gw\_id](#input\_target\_api\_gw\_id) | ID of the api to add the lambda proxy endpoint to | `string` | n/a | yes |
| <a name="input_target_api_gw_root_resource_id"></a> [target\_api\_gw\_root\_resource\_id](#input\_target\_api\_gw\_root\_resource\_id) | Root resource ID of the api gateway resource to add the lambda proxy endpoint to | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | (Optional) Name of the project | `string` | `"ldap-maintainer"` | no |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | Name of the api stage to deploy | `string` | `"ldapmaintainer"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to this module's resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_gw_role_arn"></a> [api\_gw\_role\_arn](#output\_api\_gw\_role\_arn) | ARN of the IAM role assigned to the API gateway |
| <a name="output_invoke_url"></a> [invoke\_url](#output\_invoke\_url) | Base url used to invoke this module's api endpoints |
| <a name="output_slack_listener_api_endpoint_arn"></a> [slack\_listener\_api\_endpoint\_arn](#output\_slack\_listener\_api\_endpoint\_arn) | ARN of the slack listener API endpoint |

<!-- END TFDOCS -->
