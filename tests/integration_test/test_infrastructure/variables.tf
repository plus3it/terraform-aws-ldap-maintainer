variable "tags" {
  type    = map(string)
  default = {}
}

variable "project_name" {
  type        = string
  default     = "ldapmaint-test"
  description = "Name of the project"
}

variable "directory_name" {
  type        = string
  description = "DNS name of the SimpleAD directory"
}

variable "size" {
  type        = string
  default     = "Small"
  description = "The size of the SimpleAD directory"
}

variable "certificate_arn" {
  type        = string
  description = "ARN of the certificate to back the LDAPS endpoint"
}

variable "target_zone_name" {
  type        = string
  description = "Name of the zone in which to create the simplead DNS record"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Subnet of the VPC in CIDR notation"
}

variable "vpc_azs" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  description = "List of azs to deploy the VPC"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "List of private subnets in CIDR notation"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.101.0/24"]
  description = "List of public subnets in CIDR notation"
}

variable "key_pair_name" {
  type        = string
  description = "Name of the keypair to associate with the provisioned instance"
}

variable "additional_ips_allow_inbound" {
  type        = list(string)
  default     = []
  description = "List of IP addresses in CIDR notation to allow inbound on the provisioned sg"
}

variable "instance_profile" {
  type        = string
  description = "Name of the instance profile to attach to the provisioned instance"
  default     = ""
}

variable "create_windows_instance" {
  type        = bool
  default     = true
  description = "Boolean used to control the creation of the windows domain member"
}

variable "create_dynamodb" {
  type        = bool
  default     = true
  description = "Boolean used to control the creation of the dynamodb table"
}

variable "filter_prefixes" {
  default     = []
  description = "List of user name prefixes to filter out of the user search results"
  type        = list(string)
}

variable "additional_test_users" {
  default     = []
  description = "List of additional test users to create in the target SimpleAD instance"
  type        = list(string)
}
