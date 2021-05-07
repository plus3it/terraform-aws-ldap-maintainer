# Windows Domain Member

Deploys a domain joined windows instance with AD tools

<!-- BEGIN TFDOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_http"></a> [http](#provider\_http) | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ami.windows2016](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [http_http.ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_instance_subnet"></a> [instance\_subnet](#input\_instance\_subnet) | Id of the subnet in which to place the provisioned instance | `string` | n/a | yes |
| <a name="input_key_pair_name"></a> [key\_pair\_name](#input\_key\_pair\_name) | Name of the keypair to associate with the provisioned instance | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the target VPC in which to provision the windows instance | `string` | n/a | yes |
| <a name="input_additional_ips_allow_inbound"></a> [additional\_ips\_allow\_inbound](#input\_additional\_ips\_allow\_inbound) | List of IP addresses in CIDR notation to allow inbound on the provisioned sg | `list(string)` | `[]` | no |
| <a name="input_create_windows_instance"></a> [create\_windows\_instance](#input\_create\_windows\_instance) | Boolean used to control the creation of this module's resources | `bool` | `true` | no |
| <a name="input_directoryId"></a> [directoryId](#input\_directoryId) | Id of the target directory to include in the domain join SSM document | `string` | `""` | no |
| <a name="input_directoryName"></a> [directoryName](#input\_directoryName) | Name of the target directory to include in the domain join SSM document | `string` | `""` | no |
| <a name="input_directoryOU"></a> [directoryOU](#input\_directoryOU) | Distinguished name of the OU where domain joined resources will be added | `string` | `""` | no |
| <a name="input_dnsIpAddresses"></a> [dnsIpAddresses](#input\_dnsIpAddresses) | List of DNS IP addresses to associate with the domain join SSM document | `list(string)` | `[]` | no |
| <a name="input_instance_profile"></a> [instance\_profile](#input\_instance\_profile) | Name of the instance profile to attach to the provisioned instance | `string` | `""` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type of the provisioned instance | `string` | `"t3.medium"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"ldapmaint-test"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of strings to apply as tags to provisioned resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Public IP address of the windows instance |

<!-- END TFDOCS -->
