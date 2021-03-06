output "invoke_url" {
  description = "Base url used to invoke this module's api endpoints"
  value       = aws_api_gateway_deployment.this.invoke_url
}

output "slack_listener_api_endpoint_arn" {
  description = "ARN of the slack listener API endpoint"
  value       = local.slack_listener_api_endpoint_arn
}

output "api_gw_role_arn" {
  description = "ARN of the IAM role assigned to the API gateway"
  value       = aws_iam_role.api_gw.arn
}

output "name" {
  description = "Name of the generated rest api"
  value       = aws_api_gateway_rest_api.api.name
}
