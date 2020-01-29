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
## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| artifacts\_bucket\_name | Name of the artifacts bucket | `string` | n/a | yes |
| domain\_base\_dn | Distinguished name of the domain | `string` | n/a | yes |
| ldaps\_url | LDAPS URL of the target domain | `string` | n/a | yes |
| svc\_user\_dn | Distinguished name of the user account used to manage simpleAD | `string` | n/a | yes |
| svc\_user\_pwd\_ssm\_key | SSM parameter key that contains the service account password | `string` | n/a | yes |
| vpc\_id | ID of the VPC hosting your Simple AD instance | `string` | n/a | yes |
| additional\_hands\_off\_accounts | List of accounts that will never be disabled | `list(string)` | `[]` | no |
| days\_since\_pwdlastset | Number of days since the pwdLastSet ldap attribute has been updated. This metric is used to disable the target ldap object. | `number` | `120` | no |
| log\_level | Log level of the lambda output, one of: Debug, Info, Warning, Error, or Critical | `string` | `"Info"` | no |
| project\_name | Name of the project | `string` | `"ldap-maintainer"` | no |
| tags | Map of tags to assign to this module's resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| function\_arn | The ARN of the Lambda function |
| function\_invoke\_arn | The Invoke ARN of the Lambda function |
| function\_name | The name of the Lambda function |
| function\_qualified\_arn | The qualified ARN of the Lambda function |
| role\_arn | The ARN of the IAM role created for the Lambda function |
| role\_name | The name of the IAM role created for the Lambda function |

<!-- END TFDOCS -->
