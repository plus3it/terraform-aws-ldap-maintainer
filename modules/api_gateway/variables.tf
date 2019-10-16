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

variable "slack_event_listener_sqs_queue_name" {
  type        = string
  description = "Name of the sqs queue where slack events will be published"
}

