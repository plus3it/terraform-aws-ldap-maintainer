variable "container_name" {
  type        = string
  default     = "LayerCreator"
  description = "(Optional) Name to assign to the docker container"
}

variable "docker_mounts" {
  type        = list(map(string))
  default     = []
  description = "(Optional) List of maps containing additional docker mounts. Note: these must be absolute paths"
}

variable "docker_commands" {
  type        = list(string)
  default     = []
  description = "(Optional) additional commands to run in the docker container"
}

variable "dockerfile" {
  type        = string
  default     = ""
  description = "(Optional) Full file path to the dockerfile in which the layer will be created"
}

variable "docker_image_name" {
  type        = string
  default     = ""
  description = "(Optional) Name to assign to the docker image"
}

variable "layer_build_script" {
  type        = string
  default     = ""
  description = "(Optional) Full file path to the layer build script"
}

variable "docker_bindmounts" {
  type        = list(string)
  default     = []
  description = "(Optional) List of directories to bind to the docker image"
}

variable "target_lambda_path" {
  type        = string
  default     = ""
  description = "(Optional) Full file path to the target lambda function"
}

variable "additional_docker_bindmounts" {
  type        = list(string)
  default     = []
  description = "(Optional) List of additional bind mounts to provide the layer creation docker image"
}

variable "layer_build_command" {
  type        = string
  default     = ""
  description = "(Optional) command to send to the docker image to trigger the layer creation"
}

variable "layer_name" {
  type        = string
  description = "Name to associate with the resulting layer"
}

variable "layer_description" {
  type        = string
  description = "Description to associate with the resulting layer"
}

variable "compatible_runtimes" {
  type        = list(string)
  default     = []
  description = "(Optional) A list of Runtimes this layer is compatible with. Up to 5 runtimes can be specified."
}
