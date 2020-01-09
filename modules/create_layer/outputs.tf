output "layer_arn" {
  value = chomp(null_resource.contents.triggers["stdout"])
}
