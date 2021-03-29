output "slack_event_listener_endpoint" {
  description = "Endpoint to use for the slack app's Interactivity Request URL"
  value       = "${module.api_gateway.invoke_url}/event-listener"
}

output "slack_bot_listener_endpoint" {
  description = "Endpoint to use for the slack app's Slash Command Request URL"
  value       = "${module.api_gateway.invoke_url}/slackbot"
}

output "python_ldap_layer_arn" {
  description = "ARN of the python-ldap layer"
  value       = module.ldap_query_lambda.python_ldap_layer_arn
}
