# LDAP Query Lambda Function

Lambda function that is used to perform actions against a target ldap database

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional\_hands\_off\_accounts | List of accounts to prevent from ever disabling | list(string) | `<list>` | no |
| additional\_off\_accounts |  | list | `<list>` | no |
| artifacts\_bucket\_name | Name of the artifacts bucket | string | n/a | yes |
| domain\_base\_dn | Distinguished name of the domain | string | n/a | yes |
| filter\_prefixes | List of three letter user name prefixes to filter out of the user search results | list(string) | `<list>` | no |
| ldaps\_url | LDAPS URL of the target domain | string | n/a | yes |
| log\_level | Log level of the lambda output, one of: Debug, Info, Warning, Error, or Critical | string | `"Info"` | no |
| project\_name | Name of the project | string | `"ldap-maintainer"` | no |
| svc\_user\_dn | Distinguished name of the user account used to manage simpleAD | string | n/a | yes |
| svc\_user\_pwd\_ssm\_key | SSM parameter key that contains the service account password | string | n/a | yes |
| tags | Map of tags to assign to this module's resources | map(string) | `<map>` | no |
| vpc\_id | ID of the VPC hosting your Simple AD instance | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| function\_arn | The ARN of the Lambda function |
| function\_invoke\_arn | The Invoke ARN of the Lambda function |
| function\_name | The name of the Lambda function |
| function\_qualified\_arn | The qualified ARN of the Lambda function |
| role\_arn | The ARN of the IAM role created for the Lambda function |
| role\_name | The name of the IAM role created for the Lambda function |

