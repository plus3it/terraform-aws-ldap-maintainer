data "aws_s3_bucket" "artifacts" {
  count = var.create_function ? 1 : 0

  bucket = var.artifacts_bucket_name
}

data "aws_iam_policy_document" "lambda" {
  count = var.create_function ? 1 : 0

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
    resources = [data.aws_s3_bucket.artifacts[0].arn]
  }
}

module "lambda" {
  source = "github.com/userhas404d/terraform-aws-lambda?ref=conditional"

  create_resources = var.create_function

  function_name = "${var.project_name}-db-removal-${var.resource_name_suffix}"
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
      DAYS_SINCE_PWDLASTSET = var.days_since_pwdlastset
    }
  }

  policy = {
    json = join("", data.aws_iam_policy_document.lambda.*.json)
  }

}
