data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

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
    sid     = "AllowReadSSMParam"
    actions = ["ssm:GetParameter*"]
    resources = [
      "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter${var.svc_user_pwd_ssm_key}"
    ]
  }

  statement {
    sid = "AllowS3Write"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:PutObject"
    ]
    resources = [data.aws_s3_bucket.artifacts.arn]
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = var.vpc_id

  filter {
    name   = "tag:Network"
    values = ["Private"]
  }
}

resource "aws_security_group" "lambda" {
  name        = "${var.project_name}-ldap-query-sg-${random_string.this.result}"
  description = "SG used by the ${var.project_name}-ldap-query-sg lambda function"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename         = "${path.module}/lambda_layer_payload.zip"
  layer_name       = "python-ldap-${random_string.this.result}"
  description      = "Contains python-ldap and its dependencies"
  source_code_hash = "${filebase64sha256("${path.module}/lambda_layer_payload.zip")}"

  compatible_runtimes = ["python3.7"]
}

locals {
  default_hands_off = [
    "Administrator",
    "Guest",
    "AWS_WorkSpacesAdmin",
    "AWS_WorkMail_Consul",
    "krbtgt"
  ]
  hands_off_accounts = concat(local.default_hands_off, var.additional_hands_off_accounts)
}

module "lambda" {
  source = "github.com/claranet/terraform-aws-lambda"

  function_name = "ldap-maintainer-${random_string.this.result}"
  description   = "Performs ldap query tasks"
  handler       = "lambda.handler"
  runtime       = "python3.7"
  timeout       = 300

  source_path = "${path.module}/lambda"

  policy = {
    json = data.aws_iam_policy_document.lambda.json
  }

  environment = {
    variables = {
      LDAPS_URL          = var.ldaps_url
      DOMAIN_BASE        = var.domain_base_dn
      SVC_USER_DN        = var.svc_user_dn
      FILTER_PREFIXES    = jsonencode(var.filter_prefixes)
      SSM_KEY            = var.svc_user_pwd_ssm_key
      LOG_LEVEL          = var.log_level
      ARTIFACTS_BUCKET   = var.artifacts_bucket_name
      HANDS_OFF_ACCOUNTS = jsonencode(local.hands_off_accounts)
    }
  }

  vpc_config = {
    subnet_ids         = data.aws_subnet_ids.private.ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  layers = [aws_lambda_layer_version.lambda_layer.arn]
}
