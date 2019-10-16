output "invoke_url" {
  description = "Base url used to invoke this module's api endpoints"
  value       = aws_api_gateway_deployment.respond.invoke_url
}

output "slack_listener_api_endpoint_arn" {
  description = "ARN of the slack listener API endpoint"
  value       = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_method.event_listener_post.http_method}${aws_api_gateway_resource.event_listener.path}"
}

output "api_gw_role_arn" {
  description = "ARN of the IAM role assigned to the API gateway"
  value       = aws_iam_role.api_gw.arn
}
