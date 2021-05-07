# End to end Integration Test

Deploys the ldap-maintenance project alongside a SimpleAD instance

<!-- BEGIN TFDOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ARN of the certificate to back the LDAPS endpoint | `string` | n/a | yes |
| <a name="input_directory_name"></a> [directory\_name](#input\_directory\_name) | DNS name of the SimpleAD directory | `string` | n/a | yes |
| <a name="input_key_pair_name"></a> [key\_pair\_name](#input\_key\_pair\_name) | Name of the keypair to associate with the provisioned instance | `string` | n/a | yes |
| <a name="input_slack_api_token"></a> [slack\_api\_token](#input\_slack\_api\_token) | API token used by the slack client | `string` | n/a | yes |
| <a name="input_slack_channel_id"></a> [slack\_channel\_id](#input\_slack\_channel\_id) | Channel that the slack notifier will post to | `string` | n/a | yes |
| <a name="input_target_zone_name"></a> [target\_zone\_name](#input\_target\_zone\_name) | Name of the zone in which to create the simplead DNS record | `string` | n/a | yes |
| <a name="input_additional_ips_allow_inbound"></a> [additional\_ips\_allow\_inbound](#input\_additional\_ips\_allow\_inbound) | List of IP addresses in CIDR notation to allow inbound on the provisioned sg | `list(string)` | `[]` | no |
| <a name="input_additional_test_users"></a> [additional\_test\_users](#input\_additional\_test\_users) | List of additional test users to create in the target SimpleAD instance | `list(string)` | `[]` | no |
| <a name="input_create_windows_instance"></a> [create\_windows\_instance](#input\_create\_windows\_instance) | Boolean used to control the creation of the windows domain member | `bool` | `true` | no |
| <a name="input_enable_dynamodb_cleanup"></a> [enable\_dynamodb\_cleanup](#input\_enable\_dynamodb\_cleanup) | Controls wether to enable the dynamodb cleanup function. Resources will still be deployed. | `bool` | `true` | no |
| <a name="input_filter_prefixes"></a> [filter\_prefixes](#input\_filter\_prefixes) | List of user name prefixes to filter out of the user search results | `list(string)` | `[]` | no |
| <a name="input_hands_off_accounts"></a> [hands\_off\_accounts](#input\_hands\_off\_accounts) | (Optional) List of user names to filter out of the user search results | `list(string)` | `[]` | no |
| <a name="input_instance_profile"></a> [instance\_profile](#input\_instance\_profile) | Name of the instance profile to attach to the provisioned instance | `string` | `""` | no |
| <a name="input_manual_approval_timeout"></a> [manual\_approval\_timeout](#input\_manual\_approval\_timeout) | Timeout in seconds for the manual approval step. | `number` | `3600` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"ldapmaint-test"` | no |
| <a name="input_slack_signing_secret"></a> [slack\_signing\_secret](#input\_slack\_signing\_secret) | The slack application's signing secret | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_domain_admin_password"></a> [domain\_admin\_password](#output\_domain\_admin\_password) | n/a |
| <a name="output_domain_member_public_ip"></a> [domain\_member\_public\_ip](#output\_domain\_member\_public\_ip) | IP address of the windows instance used to manage AD. |
| <a name="output_slack_bot_listener_endpoint"></a> [slack\_bot\_listener\_endpoint](#output\_slack\_bot\_listener\_endpoint) | Endpoint to use for the slack app's Slash Command Request URL |
| <a name="output_slack_event_listener_endpoint"></a> [slack\_event\_listener\_endpoint](#output\_slack\_event\_listener\_endpoint) | Endpoint to use for the slack app's Interactivity Request URL |

<!-- END TFDOCS -->
