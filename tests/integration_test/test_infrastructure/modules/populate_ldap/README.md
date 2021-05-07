# Populate LDAP Lambda

Lambda function used to populate a target SimpleAD deployment with 1000+ test users for use with the ldap-maintenance project.

Names were generated using the uinames.com api with the following command: `curl https://uinames.com/api/?region=United%20States\&amount=500`

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
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet_ids.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet_ids) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_base_dn"></a> [domain\_base\_dn](#input\_domain\_base\_dn) | Distinguished name of the domain | `string` | n/a | yes |
| <a name="input_ldaps_url"></a> [ldaps\_url](#input\_ldaps\_url) | LDAPS URL for the target domain | `string` | n/a | yes |
| <a name="input_python_ldap_layer_arn"></a> [python\_ldap\_layer\_arn](#input\_python\_ldap\_layer\_arn) | ARN of the python-ldap layer | `string` | n/a | yes |
| <a name="input_svc_user_dn"></a> [svc\_user\_dn](#input\_svc\_user\_dn) | Distinguished name of the user account used to manage simpleAD | `string` | n/a | yes |
| <a name="input_svc_user_pwd"></a> [svc\_user\_pwd](#input\_svc\_user\_pwd) | SSM parameter key that contains the service account password | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID of the VPC hosting your Simple AD instance | `string` | n/a | yes |
| <a name="input_filter_prefixes"></a> [filter\_prefixes](#input\_filter\_prefixes) | List of user name prefixes to filter out of the user search results | `list(string)` | `[]` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Log level of the lambda output, one of: Debug, Info, Warning, Error, or Critical | `string` | `"Info"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"ldap-maintainer"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags | `map(string)` | `{}` | no |
| <a name="input_test_users"></a> [test\_users](#input\_test\_users) | List of test users in Firstname Lastname format | `list(string)` | `[]` | no |

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
