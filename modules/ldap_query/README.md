# LDAP Query Lambda Function

Lambda function that is used to perform actions against a target ldap database

## Overview

This function must be deployed into a VPC that has layer 3 connectivity to the target LDAP deployment.

When provided an event with the `query` action this function will:

1. Query ldap for the target objects and group them according to their time of last password change. (By default this is 120, 90, and 60 days)
2. Generate human readable and machine readable artifacts which are then placed into S3
3. Generate S3 presigned URLs of the artifacts

When provided an event with the `disable` action this function will:

1. Retrieve the previous scan results from the provided s3 object key in the disable event (the expectation is that this object was generated during the `query` run of this function)
2. Disable objects that have not have their passwords updated within the last 120 days.

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
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_s3_bucket.artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |
| [aws_subnet_ids.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet_ids) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_artifacts_bucket_name"></a> [artifacts\_bucket\_name](#input\_artifacts\_bucket\_name) | Name of the artifacts bucket | `string` | n/a | yes |
| <a name="input_domain_base_dn"></a> [domain\_base\_dn](#input\_domain\_base\_dn) | Distinguished name of the domain | `string` | n/a | yes |
| <a name="input_ldaps_url"></a> [ldaps\_url](#input\_ldaps\_url) | LDAPS URL of the target domain | `string` | n/a | yes |
| <a name="input_svc_user_dn"></a> [svc\_user\_dn](#input\_svc\_user\_dn) | Distinguished name of the user account used to manage simpleAD | `string` | n/a | yes |
| <a name="input_svc_user_pwd_ssm_key"></a> [svc\_user\_pwd\_ssm\_key](#input\_svc\_user\_pwd\_ssm\_key) | SSM parameter key that contains the service account password | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC hosting your Simple AD instance | `string` | n/a | yes |
| <a name="input_additional_hands_off_accounts"></a> [additional\_hands\_off\_accounts](#input\_additional\_hands\_off\_accounts) | List of accounts that will never be disabled | `list(string)` | `[]` | no |
| <a name="input_days_since_pwdlastset"></a> [days\_since\_pwdlastset](#input\_days\_since\_pwdlastset) | Number of days since the pwdLastSet ldap attribute has been updated. This metric is used to disable the target ldap object. | `number` | `120` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Log level of the lambda output, one of: Debug, Info, Warning, Error, or Critical | `string` | `"Info"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"ldap-maintainer"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to this module's resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | The ARN of the Lambda function |
| <a name="output_function_invoke_arn"></a> [function\_invoke\_arn](#output\_function\_invoke\_arn) | The Invoke ARN of the Lambda function |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | The name of the Lambda function |
| <a name="output_function_qualified_arn"></a> [function\_qualified\_arn](#output\_function\_qualified\_arn) | The qualified ARN of the Lambda function |
| <a name="output_python_ldap_layer_arn"></a> [python\_ldap\_layer\_arn](#output\_python\_ldap\_layer\_arn) | ARN of the python-ldap layer |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The ARN of the IAM role created for the Lambda function |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | The name of the IAM role created for the Lambda function |

<!-- END TFDOCS -->
