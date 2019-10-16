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
    sid = "ModifyDynamoDB"
    actions = [
      "dynamodb:BatchGet*",
      "dynamodb:DescribeStream",
      "dynamodb:DescribeTable",
      "dynamodb:Get*",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWrite*",
      "dynamodb:CreateTable",
      "dynamodb:Delete*",
      "dynamodb:Update*",
      "dynamodb:PutItem"
    ]
    resources = [var.dynamodb_table_arn]
  }

  statement {
    sid = "AllowWriteArtifactsBucket"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:PutObject"
    ]
    resources = [data.aws_s3_bucket.artifacts.arn]
  }
}

module "lambda" {
  source = "github.com/claranet/terraform-aws-lambda"

  function_name = "${var.project_name}-db-removal-${random_string.this.result}"
  description   = "Removes references to disabled LDAP users from a target dynamo db table."
  handler       = "lambda.handler"
  runtime       = "python3.7"
  timeout       = 30

  source_path = "${path.module}/lambda.py"

  environment = {
    variables = {
      DYNAMODB_TABLE   = var.dynamodb_table_name
      LOG_LEVEL        = var.log_level
      ARTIFACTS_BUCKET = var.artifacts_bucket_name
    }
  }

  policy = {
    json = data.aws_iam_policy_document.lambda.json
  }

}
