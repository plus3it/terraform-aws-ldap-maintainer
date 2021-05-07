# API Gateway

terraform-aws-ldap-maintainer API Gateway module

## Overview

This module will deploy an API endpoint with invoke permissions to a target lambda function. This lambda function will then be executed asynchronously when the endpoint is triggered. Currently this endpoint has only been configured to respond to slack events.

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
| [aws_lambda_function.async](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lambda_function) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_async_lambda_name"></a> [async\_lambda\_name](#input\_async\_lambda\_name) | Name of the lambda function that API gateway will invoke asynchronously | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | (Optional) Name of the project | `string` | `"ldap-maintainer"` | no |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | Name of the api stage to deploy | `string` | `"ldapmaintainer"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to this module's resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_gw_role_arn"></a> [api\_gw\_role\_arn](#output\_api\_gw\_role\_arn) | ARN of the IAM role assigned to the API gateway |
| <a name="output_invoke_url"></a> [invoke\_url](#output\_invoke\_url) | Base url used to invoke this module's api endpoints |
| <a name="output_rest_api"></a> [rest\_api](#output\_rest\_api) | Object containing the API Gateway REST API |
| <a name="output_rest_api_deployment"></a> [rest\_api\_deployment](#output\_rest\_api\_deployment) | Object containing the API Gateway REST API Deployment |
| <a name="output_slack_listener_api_endpoint_arn"></a> [slack\_listener\_api\_endpoint\_arn](#output\_slack\_listener\_api\_endpoint\_arn) | ARN of the slack listener API endpoint |

<!-- END TFDOCS -->
