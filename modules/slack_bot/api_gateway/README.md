# API Gateway

terraform-aws-ldap-maintainer API Gateway module

## Overview

This module will deploy an API endpoint that proxies requests for the slackbot Lambda function.

<!-- BEGIN TFDOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| passthrough\_lambda | Object of attributes for the lambda function that API gateway will pass information to | <pre>object({<br>    function_arn        = string<br>    function_invoke_arn = string<br>    function_name       = string<br>  })</pre> | n/a | yes |
| target\_api\_gw\_id | ID of the api to add the lambda proxy endpoint to | `string` | n/a | yes |
| target\_api\_gw\_root\_resource\_id | Root resource ID of the api gateway resource to add the lambda proxy endpoint to | `string` | n/a | yes |
| project\_name | (Optional) Name of the project | `string` | `"ldap-maintainer"` | no |
| stage\_name | Name of the api stage to deploy | `string` | `"ldapmaintainer"` | no |
| tags | Map of tags to assign to this module's resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| api\_gw\_role\_arn | ARN of the IAM role assigned to the API gateway |
| invoke\_url | Base url used to invoke this module's api endpoints |
| slack\_listener\_api\_endpoint\_arn | ARN of the slack listener API endpoint |

<!-- END TFDOCS -->
