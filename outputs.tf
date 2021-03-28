output "slack_listener_endpoint" {
  description = "API endpoint to use as the slack application's Interactive Components request URL"
  value       = "${module.api_gateway.invoke_url}/event-listener"
}

output "python_ldap_layer_arn" {
  description = "ARN of the python-ldap layer"
  value       = module.ldap_query_lambda.python_ldap_layer_arn
}
