resource "random_string" "this" {
  length  = 8
  special = false
  upper   = false
}

locals {
  sfn_execution_arn = "${replace(var.step_function_arn, "stateMachine", "execution")}:*"
}

data "aws_s3_bucket" "artifacts" {
  bucket = var.artifacts_bucket_name
}

data "aws_iam_policy_document" "lambda" {
  statement {
    sid = "AlertStepFunction"
    actions = [
      "states:*"
    ]
    resources = [
      var.step_function_arn,
      local.sfn_execution_arn
    ]
  }

  statement {
    sid = "AllowReadArtifactsBucket"
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = [data.aws_s3_bucket.artifacts.arn]
  }
}

module "lambda" {
  source = "github.com/claranet/terraform-aws-lambda"

  function_name = "${var.project_name}-slack-bot-${random_string.this.result}"
  description   = "Responds to slack mentions of the bot user."
  handler       = "lambda.handler"
  runtime       = "python3.7"
  timeout       = 30

  source_path = "${abspath(path.module)}/lambda"

  environment = {
    variables = {
      LOG_LEVEL            = var.log_level
      SFN_ARN              = var.step_function_arn
      ARTIFACTS_BUCKET     = var.artifacts_bucket_name
      SLACK_API_TOKEN      = var.slack_api_token
      SLACK_SIGNING_SECRET = var.slack_signing_secret
    }
  }

  policy = data.aws_iam_policy_document.lambda

}

module "api_gateway" {
  source = "./api_gateway"

  passthrough_lambda_name = module.lambda.function_name
  project_name            = var.project_name
  tags                    = var.tags
  target_api_gw           = var.target_api_gw
}
