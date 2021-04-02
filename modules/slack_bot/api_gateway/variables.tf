variable "tags" {
  default     = {}
  description = "Map of tags to assign to this module's resources"
  type        = map(string)
}

variable "project_name" {
  default     = "ldap-maintainer"
  description = "(Optional) Name of the project"
  type        = string
}

variable "passthrough_lambda" {
  description = "Object of attributes for the lambda function that API gateway will pass information to"
  type = object({
    function_arn        = string
    function_invoke_arn = string
    function_name       = string
  })
}

variable "target_api_gw_id" {
  description = "ID of the api to add the lambda proxy endpoint to"
  type        = string
}

variable "target_api_gw_root_resource_id" {
  description = "Root resource ID of the api gateway resource to add the lambda proxy endpoint to"
  type        = string
}

variable "stage_name" {
  description = "Name of the api stage to deploy"
  type        = string
  default     = "ldapmaintainer"
}
