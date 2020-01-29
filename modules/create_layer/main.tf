locals {
  default_docker_commands = ["bash", "-c", "chmod +x layergen/create-layer.sh && ./layergen/create-layer.sh"]
  docker_commands         = concat(local.default_docker_commands, var.docker_commands)
  docker_image_name       = var.docker_image_name == "" ? "ldapmaint/layer" : var.docker_image_name

  dockerfile          = var.dockerfile == "" ? "${abspath(path.module)}/bin/Dockerfile.layers" : var.dockerfile
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
    always_run = "${timestamp()}"
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

resource "null_resource" "create_layer" {

  depends_on = [
    null_resource.docker_image_validate
  ]

  provisioner "local-exec" {
    when        = "create"
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

# borrowing patterns from here: https://github.com/matti/terraform-shell-resource
# waiting on working_dir and environment var support to be added before using the
# module directly
resource "null_resource" "publish_layer" {

  depends_on = [
    null_resource.docker_image_validate,
    null_resource.create_layer
  ]

  provisioner "local-exec" {
    when        = "create"
    command     = "bin/publish-layer.sh 2>\"${abspath(path.module)}/stderr.${null_resource.create_layer.id}\" >\"${abspath(path.module)}/stdout.${null_resource.create_layer.id}\"; echo $? >\"${abspath(path.module)}/exitstatus.${null_resource.create_layer.id}\""
    working_dir = path.module
    environment = {
      LAYER_NAME          = var.layer_name
      LAYER_DESCRIPTION   = var.layer_description
      COMPATIBLE_RUNTIMES = jsonencode(var.compatible_runtimes)
      LAYER_ARCHIVE_NAME  = "lambda_layer_payload.zip"
      TARGET_LAMBDA_PATH  = var.target_lambda_path
    }
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "rm \"${abspath(path.module)}/stdout.${null_resource.create_layer.id}\""
    on_failure = continue
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "rm \"${abspath(path.module)}/stderr.${null_resource.create_layer.id}\""
    on_failure = continue
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "rm \"${abspath(path.module)}/exitstatus.${null_resource.create_layer.id}\""
    on_failure = continue
  }
}

data "external" "stdout" {
  depends_on = [null_resource.publish_layer]
  program    = ["sh", "${abspath(path.module)}/bin/read.sh", "${abspath(path.module)}/stdout.${null_resource.create_layer.id}"]
}

data "external" "stderr" {
  depends_on = [null_resource.publish_layer]
  program    = ["sh", "${abspath(path.module)}/bin/read.sh", "${abspath(path.module)}/stderr.${null_resource.create_layer.id}"]
}

data "external" "exitstatus" {
  depends_on = [null_resource.publish_layer]
  program    = ["sh", "${abspath(path.module)}/bin/read.sh", "${abspath(path.module)}/exitstatus.${null_resource.create_layer.id}"]
}

# could probably make this run on updates to the resulting
# layer zip but one and done is fine for now.
resource "null_resource" "contents" {
  depends_on = [
    null_resource.docker_image_validate,
    null_resource.create_layer,
    null_resource.publish_layer
  ]

  triggers = {
    stdout     = data.external.stdout.result["content"]
    stderr     = data.external.stderr.result["content"]
    exitstatus = data.external.exitstatus.result["content"]
  }

  lifecycle {
    ignore_changes = [triggers]
  }
}

# destroy the layer when terraform destroy is run
resource "null_resource" "layer_cleanup" {

  depends_on = [
    null_resource.contents
  ]

  provisioner "local-exec" {
    when        = "destroy"
    command     = "bin/delete-layer.sh"
    working_dir = path.module
    environment = {
      LAYER_ARN = chomp(null_resource.contents.triggers["stdout"])
    }
  }
}

# destroy the docker image when terraform destroy is run
resource "null_resource" "docker_image_cleanup" {

  provisioner "local-exec" {
    when    = "destroy"
    command = "docker rmi $(docker images '${local.docker_image_name}' -q) || echo 'image '${local.docker_image_name}' does not exist'"
  }
}
