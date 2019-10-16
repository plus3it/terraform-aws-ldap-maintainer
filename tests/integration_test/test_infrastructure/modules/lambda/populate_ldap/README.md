# Populate LDAP Lambda

Lambda function used to populate a target SimpleAD deployment with test users for use with the ldap-maintenance project

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| domain\_base\_dn | Distinguished name of the domain | string | n/a | yes |
| ldaps\_url | LDAPS URL for the target domain | string | n/a | yes |
| log\_level | Log level of the lambda output, one of: Debug, Info, Warning, Error, or Critical | string | `"Info"` | no |
| project\_name | Name of the project | string | `"ldap-maintainer"` | no |
| svc\_user\_dn | Distinguished name of the user account used to manage simpleAD | string | n/a | yes |
| svc\_user\_pwd | SSM parameter key that contains the service account password | string | n/a | yes |
| tags | Map of tags | map(string) | `<map>` | no |
| test\_users | List of test users in Firstname Lastname format | list(string) | `<list>` | no |
| vpc\_id | VPC ID of the VPC hosting your Simple AD instance | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| function\_arn | The ARN of the Lambda function |
| function\_invoke\_arn | The Invoke ARN of the Lambda function |
| function\_name | The name of the Lambda function |
| function\_qualified\_arn | The qualified ARN of the Lambda function |
| role\_arn | The ARN of the IAM role created for the Lambda function |
| role\_name | The name of the IAM role created for the Lambda function |

