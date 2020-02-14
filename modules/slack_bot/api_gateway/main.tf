
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_lambda_function" "passthrough" {
  function_name = var.passthrough_lambda_name
}

# create the role that API Gateway can use to call Step Functions.
data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "api_gw" {
  statement {
    actions   = ["lambda:InvokeFunction"]
    resources = [data.aws_lambda_function.passthrough.arn]
  }
}

resource "aws_iam_policy" "api_gw" {
  name        = "${var.project_name}-api-gw-slackbot"
  description = "Policy used by the Ldap Maintenance API Gateway"
  policy      = data.aws_iam_policy_document.api_gw.json
}

resource "aws_iam_role" "api_gw" {
  name = "${var.project_name}-api-gw-slackbot"

  assume_role_policy = data.aws_iam_policy_document.trust.json

  tags = var.tags
}

resource "aws_iam_policy_attachment" "api_gw" {
  name       = "ldap-maintainer-api-gw-slackbot"
  roles      = [aws_iam_role.api_gw.name]
  policy_arn = aws_iam_policy.api_gw.arn
}

data "aws_api_gateway_rest_api" "target_api" {
  name = var.target_api_gw
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = data.aws_api_gateway_rest_api.target_api.id
  parent_id   = data.aws_api_gateway_rest_api.target_api.root_resource_id
  path_part   = "slackbot"
}

resource "aws_api_gateway_method" "proxy_post" {
  rest_api_id   = data.aws_api_gateway_rest_api.target_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_listener" {
  rest_api_id = data.aws_api_gateway_rest_api.target_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy_post.http_method
  credentials = aws_iam_role.api_gw.arn
  type        = "AWS_PROXY"

  uri                     = data.aws_lambda_function.passthrough.invoke_arn
  integration_http_method = "POST"
}

locals {
  gw_execution_arn           = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${data.aws_api_gateway_rest_api.target_api.id}"
  slack_bot_api_endpoint_arn = "${local.gw_execution_arn}/*/${aws_api_gateway_method.proxy_post.http_method}${aws_api_gateway_resource.proxy.path}"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.passthrough_lambda_name
  principal     = "apigateway.amazonaws.com"

  source_arn = local.slack_bot_api_endpoint_arn
}

# deploy the api
resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    aws_api_gateway_integration.proxy_listener
  ]
  rest_api_id = data.aws_api_gateway_rest_api.target_api.id
  stage_name  = var.stage_name
}
