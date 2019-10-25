# End to end Integration Test

Deploys the ldap-maintenance project alongside a SimpleAD instance

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional\_ips\_allow\_inbound | List of IP addresses in CIDR notation to allow inbound on the provisioned sg | list(string) | `<list>` | no |
| certificate\_arn | ARN of the certificate to back the LDAPS endpoint | string | n/a | yes |
| create\_dynamodb\_cleanup | Controls wether to create the dynamodb cleanup resources | bool | `"true"` | no |
| create\_windows\_instance | Boolean used to control the creation of the windows domain member | bool | `"true"` | no |
| directory\_name | DNS name of the SimpleAD directory | string | n/a | yes |
| instance\_profile | Name of the instance profile to attach to the provisioned instance | string | `""` | no |
| key\_pair\_name | Name of the keypair to associate with the provisioned instance | string | n/a | yes |
| project\_name | Name of the project | string | `"ldapmaint-test"` | no |
| slack\_api\_token | API token used by the slack client | string | n/a | yes |
| slack\_channel\_id | Channel that the slack notifier will post to | string | n/a | yes |
| slack\_signing\_secret | The slack application's signing secret | string | `""` | no |
| target\_zone\_name | Name of the zone in which to create the simplead DNS record | string | n/a | yes |

