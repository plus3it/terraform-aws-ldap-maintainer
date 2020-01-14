variable "create_windows_instance" {
  type        = bool
  default     = true
  description = "Boolean used to control the creation of this module's resources"
}

variable "tags" {
  type        = map(string)
  description = "Map of strings to apply as tags to provisioned resources"
  default     = {}
}

variable "project_name" {
  type        = string
  default     = "ldapmaint-test"
  description = "Name of the project"
}

variable "additional_ips_allow_inbound" {
  type        = list(string)
  default     = []
  description = "List of IP addresses in CIDR notation to allow inbound on the provisioned sg"
}

variable "vpc_id" {
  type        = string
  description = "ID of the target VPC in which to provision the windows instance"
}

variable "key_pair_name" {
  type        = string
  description = "Name of the keypair to associate with the provisioned instance"
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Instance type of the provisioned instance"
}

variable "directoryId" {
  type        = string
  description = "Id of the target directory to include in the domain join SSM document"
  default     = ""
}

variable "directoryName" {
  type        = string
  description = "Name of the target directory to include in the domain join SSM document"
  default     = ""
}

variable "directoryOU" {
  type        = string
  description = "Distinguished name of the OU where domain joined resources will be added"
  default     = ""
}

variable "dnsIpAddresses" {
  type        = list(string)
  description = "List of DNS IP addresses to associate with the domain join SSM document"
  default     = []
}

variable "instance_subnet" {
  type        = string
  description = "Id of the subnet in which to place the provisioned instance"
}

variable "instance_profile" {
  type        = string
  description = "Name of the instance profile to attach to the provisioned instance"
  default     = ""
}
