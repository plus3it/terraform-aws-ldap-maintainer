# End to end Integration Test

Deploys the ldap-maintenance project alongside a SimpleAD instance

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional\_ips\_allow\_inbound | List of IP addresses in CIDR notation to allow inbound on the provisioned sg | list(string) | `<list>` | no |
| additional\_test\_users | List of additional test users to create in the target SimpleAD instance | list(string) | `<list>` | no |
| certificate\_arn | ARN of the certificate to back the LDAPS endpoint | string | n/a | yes |
| create\_windows\_instance | Boolean used to control the creation of the windows domain member | bool | `"true"` | no |
| directory\_name | DNS name of the SimpleAD directory | string | n/a | yes |
| enable\_dynamodb\_cleanup | Controls wether to enable the dynamodb cleanup function. Resources will still be deployed. | bool | `"true"` | no |
| filter\_prefixes | List of user name prefixes to filter out of the user search results | list(string) | `<list>` | no |
| hands\_off\_accounts | \(Optional\) List of user names to filter out of the user search results | list(string) | `<list>` | no |
| instance\_profile | Name of the instance profile to attach to the provisioned instance | string | `""` | no |
| key\_pair\_name | Name of the keypair to associate with the provisioned instance | string | n/a | yes |
| project\_name | Name of the project | string | `"ldapmaint-test"` | no |
| slack\_api\_token | API token used by the slack client | string | n/a | yes |
| slack\_channel\_id | Channel that the slack notifier will post to | string | n/a | yes |
| slack\_signing\_secret | The slack application's signing secret | string | `""` | no |
| target\_zone\_name | Name of the zone in which to create the simplead DNS record | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| domain\_member\_public\_ip | IP address of the windows instance used to manage AD. |
| slack\_listener\_endpoint | API endpoint to use as the slack application's Interactive Components request URL |

