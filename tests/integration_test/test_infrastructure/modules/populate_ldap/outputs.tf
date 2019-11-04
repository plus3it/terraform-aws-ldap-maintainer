output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = module.lambda.function_arn
}

output "function_invoke_arn" {
  description = "The Invoke ARN of the Lambda function"
  value       = module.lambda.function_invoke_arn
}

output "function_name" {
  description = "The name of the Lambda function"
  value       = module.lambda.function_name
}

output "function_qualified_arn" {
  description = "The qualified ARN of the Lambda function"
  value       = module.lambda.function_qualified_arn
}

output "role_arn" {
  description = "The ARN of the IAM role created for the Lambda function"
  value       = module.lambda.role_arn
}

output "role_name" {
  description = "The name of the IAM role created for the Lambda function"
  value       = module.lambda.role_name
}
