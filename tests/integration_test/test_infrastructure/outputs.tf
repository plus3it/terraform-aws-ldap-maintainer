output "ldaps_url" {
  value = "ldaps://${aws_lb.ldaps.dns_name}"
}

output "domain_base_dn" {
  value = local.dn
}

output "svc_user_dn" {
  value = "CN=Administrator,CN=Users,${local.dn}"
}

output "svc_user_pwd_ssm_key" {
  value = aws_ssm_parameter.simplead_password.name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "dynamodb_table_name" {
  value = join("", aws_dynamodb_table.test_table.*.name)
}

output "dynamodb_table_arn" {
  value = join("", aws_dynamodb_table.test_table.*.arn)
}
