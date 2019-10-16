output "slack_listener_endpoint" {
  description = "API endpoint to use as the slack application's Interactive Components request URL"
  value       = "${module.api_gateway.invoke_url}/event-listener"
}
