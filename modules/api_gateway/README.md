# API Gateway

terraform-aws-ldap-maintainer API Gateway module

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| project\_name | (Optional) Name of the project | string | `"ldap-maintainer"` | no |
| slack\_event\_listener\_sqs\_queue\_name | Name of the sqs queue where slack events will be published | string | n/a | yes |
| tags | Map of tags to assign to this module's resources | map(string) | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| api\_gw\_role\_arn | ARN of the IAM role assigned to the API gateway |
| invoke\_url | Base url used to invoke this module's api endpoints |
| slack\_listener\_api\_endpoint\_arn | ARN of the slack listener API endpoint |

