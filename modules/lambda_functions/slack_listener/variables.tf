variable "project_name" {
  default     = "ldap-maintainer"
  description = "Name of the project"
  type        = string
}

variable "slack_api_token" {
  description = "API token used by the slack client"
  type        = string
}

variable "log_level" {
  default     = "Info"
  description = "Log level of the lambda output, one of: Debug, Info, Warning, Error, or Critical"
  type        = string
}

variable "slack_listener_api_endpoint_arn" {
  default     = ""
  description = ""
  type        = string
}

variable "slack_signing_secret" {
  default     = ""
  description = "The slack application's signing secret"
  type        = string
}

variable "step_function_arns" {
  description = "List of state machine ARNs that the api gateway is able to perform actions against"
  type        = list(string)
}

variable "tags" {
  default     = {}
  description = "Map of tags to assign to this module's resources"
  type        = map(string)
}

variable "api_gw_role_arn" {
  description = "ARN of the IAM role assigned to the API gateway"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "Name of the artifacts bucket"
  type        = string
}
