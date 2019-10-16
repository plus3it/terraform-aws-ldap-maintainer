variable "project_name" {
  default     = "ldap-maintainer"
  description = "Name of the project"
  type        = string
}

variable "slack_api_token" {
  description = "API token used by the slack client"
  type        = string
}

variable "slack_channel_id" {
  description = "Channel that the slack notifier will post to"
  type        = string
}

variable "sfn_activity_arn" {
  description = "ARN of the state machine activity to query for a taskToken"
  type        = string
}

variable "invoke_base_url" {
  description = "Base URL of the api gateway endpoint to pass to slack for approve/deny actions"
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

variable "timezone" {
  default     = "US/Eastern"
  description = "(Optional)Timezone that the slack notifications will be timestamped with"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "Name of the artifacts bucket"
  type        = string
}

variable "tags" {
  description = "Map of tags to assign to this module's resources"
  type        = map(string)
  default     = {}
}
