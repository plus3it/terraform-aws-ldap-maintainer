variable "project_name" {
  default     = "ldap-maintainer"
  description = "Name of the project"
  type        = string
}

variable "ldaps_url" {
  description = "LDAPS URL of the target domain"
  type        = string
}

variable "domain_base_dn" {
  description = "Distinguished name of the domain"
  type        = string
}

variable "svc_user_dn" {
  description = "Distinguished name of the LDAP Maintenance service account used to manage simpleAD"
  type        = string
}

variable "svc_user_pwd_ssm_key" {
  description = "SSM parameter key that contains the LDAP Maintenance service account password"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC hosting the target Simple AD instance"
  type        = string
}

variable "slack_api_token" {
  description = "API token used by the slack client"
  type        = string
}

variable "slack_signing_secret" {
  description = "The slack application's signing secret"
  type        = string
}

variable "slack_channel_id" {
  description = "Channel that the slack notifier will post to"
  type        = string
}

variable "log_level" {
  default     = "Info"
  description = "(Optional) Log level of the lambda output, one of: Debug, Info, Warning, Error, or Critical"
  type        = string
}

variable "filter_prefixes" {
  default     = []
  description = "(Optional) List of three letter user name prefixes to filter out of the user search results"
  type        = list(string)
}

variable "dynamodb_table_name" {
  description = "Name of the dynamodb to take actions against"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "ARN of the dynamodb to take actions against"
  type        = string
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Map of tags to assign to this module's resources"
}

variable "maintenance_schedule" {
  type = string
  # Run at 8:00 am (UTC) every 1st day of the month
  default     = "cron(0 8 1 * ? *)"
  description = "Periodicity at which to trigger the ldap maintenance step function"
}

variable "create_dynamodb_cleanup" {
  type        = bool
  default     = true
  description = "Controls wether to create the dynamodb cleanup resources"
}

variable "additional_cleanup_tasks" {
  type        = string
  default     = ""
  description = "(Optional) List of step function tasks to execute in parallel once the cleanup action has been approved."
}
