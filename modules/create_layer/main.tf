locals {
  default_docker_commands = ["bash", "-c", "chmod +x layergen/create-layer.sh && ./layergen/create-layer.sh"]
  docker_commands         = concat(local.default_docker_commands, var.docker_commands)
  docker_image_name       = var.docker_image_name == "" ? "ldapmaint/layer" : var.docker_image_name

  dockerfile          = var.dockerfile == "" ? "${path.module}/bin/Dockerfile.layers" : var.dockerfile
  layer_build_script  = var.layer_build_script == "" ? "${abspath(path.module)}/bin/create-layer.sh" : var.layer_build_script
  layer_build_command = var.layer_build_command == "" ? "bash -c './bin/create-layer.sh'" : var.layer_build_command

  bindmount_root               = "/home/lambda-layer"
  layer_build_script_bindmount = ["${dirname(local.layer_build_script)}:${local.bindmount_root}/bin"]
  lambda_bindmount             = ["${var.target_lambda_path}:${local.bindmount_root}/${basename(var.target_lambda_path)}"]
  additional_docker_bindmounts = var.additional_docker_bindmounts == [] ? [] : var.additional_docker_bindmounts
  docker_bindmounts            = concat(local.layer_build_script_bindmount, local.lambda_bindmount, local.additional_docker_bindmounts)
}

# check if the docker image exists on the current system
resource "null_resource" "docker_image_validate" {
  # re-run if the specified dockerfile changes
  triggers = {
    dockerfile         = filemd5(local.dockerfile)
    layer_build_script = filemd5(local.layer_build_script)
  }

  provisioner "local-exec" {
    command     = "bin/docker-image-validate.sh"
    working_dir = path.module
    environment = {
      DOCKERFILE = local.dockerfile
      IMAGE_NAME = local.docker_image_name
    }
  }
}

# create the layer via the target docker image
resource "null_resource" "create_layer" {
  depends_on = [
    null_resource.docker_image_validate
  ]

  provisioner "local-exec" {
    command     = "bin/docker-run.sh"
    working_dir = path.module
    environment = {
      BINDMOUNT_ROOT      = local.bindmount_root
      DOCKER_BINDMOUNTS   = jsonencode(local.docker_bindmounts)
      IMAGE_NAME          = local.docker_image_name
      LAYER_BUILD_COMMAND = local.layer_build_command
      LAYER_BUILD_SCRIPT  = local.layer_build_script
    }
  }
}

locals {
  layer_path = "${var.target_lambda_path}/lambda_layer_payload.zip"
}

resource "aws_lambda_layer_version" "lambda_layer" {
  depends_on = [
    null_resource.create_layer
  ]

  filename    = local.layer_path
  layer_name  = var.layer_name
  description = var.layer_description
  # filebase64sha256 is computed before depends_on resolves :(
  # source_code_hash = filebase64sha256(local.layer_path)

  compatible_runtimes = var.compatible_runtimes
}

# destroy the docker image when terraform destroy is run
resource "null_resource" "docker_image_cleanup" {

  provisioner "local-exec" {
    when    = "destroy"
    command = "docker rmi $(docker images '${local.docker_image_name}' -q) || echo 'image '${local.docker_image_name}' does not exist'"
  }
}

