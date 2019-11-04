resource "random_string" "this" {
  length  = 8
  special = false
  upper   = false
}

data "aws_s3_bucket" "artifacts" {
  bucket = var.artifacts_bucket_name
}

data "aws_iam_policy_document" "lambda" {
  # need to make this less permissive
  statement {
    sid = "AlertStepFunction"
    actions = [
      "states:*"
    ]
    resources = var.step_function_arns
  }

  statement {
    sid = "AllowS3Write"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:PutObject"
    ]
    resources = [
      data.aws_s3_bucket.artifacts.arn
    ]
  }
}

module "lambda" {
  source = "github.com/claranet/terraform-aws-lambda"

  function_name = "${var.project_name}-slack-listener-${random_string.this.result}"
  description   = "Listens for slack events."
  handler       = "lambda.handler"
  runtime       = "python3.7"
  timeout       = 30

  source_path = "${path.module}/lambda.py"

  environment = {
    variables = {
      ARTIFACTS_BUCKET     = var.artifacts_bucket_name
      LOG_LEVEL            = var.log_level
      SLACK_API_TOKEN      = var.slack_api_token
      SLACK_SIGNING_SECRET = var.slack_signing_secret
    }
  }

  policy = {
    json = data.aws_iam_policy_document.lambda.json
  }

}
