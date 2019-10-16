variable "project_name" {
  default     = "ldap-maintainer"
  description = "Name of the project"
  type        = string
}

variable "ldaps_url" {
  description = "LDAPS URL for the target domain"
  type        = string
}

variable "domain_base_dn" {
  description = "Distinguished name of the domain"
  type        = string
}

variable "svc_user_dn" {
  description = "Distinguished name of the user account used to manage simpleAD"
  type        = string
}

variable "svc_user_pwd" {
  description = "SSM parameter key that contains the service account password"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID of the VPC hosting your Simple AD instance"
  type        = string
}

variable "log_level" {
  default     = "Info"
  description = "Log level of the lambda output, one of: Debug, Info, Warning, Error, or Critical"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Map of tags"
  type        = map(string)
}

variable "test_users" {
  default     = []
  type        = list(string)
  description = "List of test users in Firstname Lastname format"
}
