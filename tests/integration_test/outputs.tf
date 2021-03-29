output "domain_member_public_ip" {
  value       = module.test_infrastructure.domain_member_public_ip
  description = "IP address of the windows instance used to manage AD."
}

output "slack_event_listener_endpoint" {
  value       = module.ldap_maintainer.slack_event_listener_endpoint
  description = "Endpoint to use for the slack app's Interactivity Request URL"
}

output "slack_bot_listener_endpoint" {
  value       = module.ldap_maintainer.slack_bot_listener_endpoint
  description = "Endpoint to use for the slack app's Slash Command Request URL"
}

output "domain_admin_password" {
  value     = module.test_infrastructure.domain_admin_password
  sensitive = true
}
