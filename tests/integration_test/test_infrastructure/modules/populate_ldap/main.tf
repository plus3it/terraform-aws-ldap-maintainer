data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "random_string" "this" {
  length  = 8
  special = false
  upper   = false
}

data "aws_subnet_ids" "private" {
  vpc_id = var.vpc_id

  filter {
    name   = "tag:Network"
    values = ["Private"]
  }
}

resource "aws_security_group" "lambda" {
  name        = "${var.project_name}-ldap-populator-sg-${random_string.this.result}"
  description = "SG used by the ${var.project_name}-ldap-populator-sg lambda function"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "lambda_layer" {
  source = "../../../../../modules/create_layer"

  target_lambda_path = "${abspath(path.module)}"
  layer_name         = "python-ldap-${random_string.this.result}"
  layer_description  = "Contains python-ldap and its dependencies"

  compatible_runtimes = ["python3.7"]
}

module "lambda" {
  source = "github.com/claranet/terraform-aws-lambda"

  function_name = "ldap-populator-${random_string.this.result}"
  description   = "Creates test users in standalone simplead instance"
  handler       = "lambda.handler"
  runtime       = "python3.7"
  timeout       = 90

  source_path = "${path.module}/lambda"

  environment = {
    variables = {
      LDAPS_URL       = var.ldaps_url
      DOMAIN_BASE     = var.domain_base_dn
      SVC_USER_DN     = var.svc_user_dn
      SVC_USER_PWD    = var.svc_user_pwd
      LOG_LEVEL       = var.log_level
      TEST_USERS      = jsonencode(var.test_users)
      FILTER_PREFIXES = jsonencode(var.filter_prefixes)
    }
  }

  vpc_config = {
    subnet_ids         = data.aws_subnet_ids.private.ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  layers = [module.lambda_layer.layer_arn]
}
