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

variable "passthrough_lambda_name" {
  description = "Name of the lambda function that API gateway will pass information to"
  type        = string
}

variable "target_api_gw" {
  description = "Name of the api to add the lambda proxy endpoint to"
  type        = string
}

variable "stage_name" {
  description = "Name of the api stage to deploy"
  type        = string
  default     = "ldapmaintainer"
}
