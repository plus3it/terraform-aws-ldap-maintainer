output "domain_member_public_ip" {
  value       = module.test_infrastructure.domain_member_public_ip
  description = "IP address of the windows instance used to manage AD."
}

output "slack_listener_endpoint" {
  value       = module.ldap_maintainer.slack_listener_endpoint
  description = "API endpoint to use as the slack application's Interactive Components request URL"
}

output "domain_admin_password" {
  value     = module.test_infrastructure.domain_admin_password
  sensitive = true
}
