# Windows Domain Member

Deploys a domain joined windows instance with AD tools

<!-- BEGIN TFDOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| http | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| instance\_subnet | Id of the subnet in which to place the provisioned instance | `string` | n/a | yes |
| key\_pair\_name | Name of the keypair to associate with the provisioned instance | `string` | n/a | yes |
| vpc\_id | ID of the target VPC in which to provision the windows instance | `string` | n/a | yes |
| additional\_ips\_allow\_inbound | List of IP addresses in CIDR notation to allow inbound on the provisioned sg | `list(string)` | `[]` | no |
| create\_windows\_instance | Boolean used to control the creation of this module's resources | `bool` | `true` | no |
| directoryId | Id of the target directory to include in the domain join SSM document | `string` | `""` | no |
| directoryName | Name of the target directory to include in the domain join SSM document | `string` | `""` | no |
| directoryOU | Distinguished name of the OU where domain joined resources will be added | `string` | `""` | no |
| dnsIpAddresses | List of DNS IP addresses to associate with the domain join SSM document | `list(string)` | `[]` | no |
| instance\_profile | Name of the instance profile to attach to the provisioned instance | `string` | `""` | no |
| instance\_type | Instance type of the provisioned instance | `string` | `"t3.medium"` | no |
| project\_name | Name of the project | `string` | `"ldapmaint-test"` | no |
| tags | Map of strings to apply as tags to provisioned resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| public\_ip | Public IP address of the windows instance |

<!-- END TFDOCS -->
