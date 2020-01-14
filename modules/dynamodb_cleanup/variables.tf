variable "project_name" {
  default     = "ldap-maintainer"
  description = "Name of the project"
  type        = string
}

variable "log_level" {
  default     = "Info"
  description = "(Optional) Log level of the lambda output, one of: Debug, Info, Warning, Error, or Critical"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Map of tags to assign to this module's resources"
  type        = map(string)
}

variable "dynamodb_table_name" {
  description = "Name of the dynamodb to take actions against"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "ARN of the dynamodb table to perform maintenance actions against"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "Name of the artifacts bucket"
  type        = string
}

variable "resource_name_suffix" {
  default     = ""
  description = "Suffix to append this module's resource names"
  type        = string
}

variable "days_since_pwdlastset" {
  description = "Number of days since the pwdLastSet ldap attribute has been updated. This metric is used to disable the target ldap object."
  type        = number
  default     = 120
}
