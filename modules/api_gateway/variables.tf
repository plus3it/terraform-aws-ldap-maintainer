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

variable "async_lambda_name" {
  type        = string
  description = "Name of the lambda function that API gateway will invoke asynchronously"
}
