module "api_gateway" {
  source = "./modules/api_gateway"

  project_name      = var.project_name
  async_lambda_name = module.slack_event_listener.function_name
}

module "slack_event_listener" {
  source = "./modules/slack_listener"

  project_name          = var.project_name
  artifacts_bucket_name = aws_s3_bucket.artifacts.id
  slack_api_token       = var.slack_api_token
  slack_signing_secret  = var.slack_signing_secret
  step_function_arn     = aws_sfn_state_machine.ldap_maintenance.id

  slack_listener_api_endpoint_arn = module.api_gateway.slack_listener_api_endpoint_arn

  log_level = var.log_level
}

module "ldap_query_lambda" {
  source = "./modules/ldap_query"

  project_name                  = var.project_name
  artifacts_bucket_name         = aws_s3_bucket.artifacts.id
  ldaps_url                     = var.ldaps_url
  domain_base_dn                = var.domain_base_dn
  additional_hands_off_accounts = var.hands_off_accounts
  svc_user_dn                   = var.svc_user_dn
  svc_user_pwd_ssm_key          = var.svc_user_pwd_ssm_key
  vpc_id                        = var.vpc_id
  days_since_pwdlastset         = var.days_since_pwdlastset

  log_level = var.log_level
}

module "slack_notifier" {
  source = "./modules/slack_notifier"

  project_name          = var.project_name
  artifacts_bucket_name = aws_s3_bucket.artifacts.id
  slack_channel_id      = var.slack_channel_id
  slack_api_token       = var.slack_api_token
  sfn_activity_arn      = aws_sfn_activity.account_deactivation_approval.id
  invoke_base_url       = module.api_gateway.invoke_url
  days_since_pwdlastset = var.days_since_pwdlastset

  log_level = var.log_level
}

module "slack_bot" {
  source = "./modules/slack_bot"

  project_name                   = var.project_name
  step_function_arn              = aws_sfn_state_machine.ldap_maintenance.id
  target_api_gw_id               = module.api_gateway.rest_api_deployment.rest_api_id
  target_api_gw_root_resource_id = module.api_gateway.rest_api.root_resource_id
  slack_signing_secret           = var.slack_signing_secret
  slack_api_token                = var.slack_api_token
  artifacts_bucket_name          = aws_s3_bucket.artifacts.id

  log_level = var.log_level
}

module "dynamodb_cleanup" {
  source = "./modules/dynamodb_cleanup"

  project_name          = var.project_name
  dynamodb_table_name   = var.dynamodb_table_name
  dynamodb_table_arn    = var.dynamodb_table_arn
  artifacts_bucket_name = aws_s3_bucket.artifacts.id

  log_level = var.log_level
}

# artifacts bucket
resource "random_string" "this" {
  length  = 8
  special = false
  upper   = false
}

locals {
  object_prefixes = ["user_expiration_table", "slack-response"]
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.project_name}-artifacts-${random_string.this.result}"

  acl           = "private"
  tags          = var.tags
  force_destroy = true

  dynamic "lifecycle_rule" {
    for_each = local.object_prefixes
    content {
      id      = lifecycle_rule.value
      enabled = true

      prefix = lifecycle_rule.value

      transition {
        days          = 30
        storage_class = "STANDARD_IA"
      }

      transition {
        days          = 60
        storage_class = "GLACIER"
      }

      expiration {
        days = 90
      }
    }
  }
}

locals {
  lambda_role_arns = compact([
    module.slack_notifier.role_arn,
    module.slack_event_listener.role_arn,
    module.ldap_query_lambda.role_arn,
    module.dynamodb_cleanup.role_arn,
    module.slack_bot.role_arn
  ])
}

resource "aws_s3_bucket_policy" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Id": "lambda_access",
      "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": ${jsonencode(local.lambda_role_arns)}
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "${aws_s3_bucket.artifacts.arn}/*"
        }
      ]
    }
    POLICY
}

locals {
  lambda_function_arns = compact([
    module.ldap_query_lambda.function_arn,
    module.slack_notifier.function_arn,
    module.dynamodb_cleanup.function_arn
  ])
}

# step function
data "aws_iam_policy_document" "sfn" {
  statement {
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = local.lambda_function_arns
  }
}

resource "aws_iam_policy" "sfn" {
  name        = "${var.project_name}-sfn"
  description = "Policy used by the ${var.project_name} Step Function"
  policy      = data.aws_iam_policy_document.sfn.json
}

data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sfn" {
  name = "${var.project_name}-sfn"

  assume_role_policy = data.aws_iam_policy_document.trust.json
}

resource "aws_iam_policy_attachment" "sfn" {
  name       = "${var.project_name}-sfn"
  roles      = [aws_iam_role.sfn.name]
  policy_arn = aws_iam_policy.sfn.arn
}

resource "aws_sfn_activity" "account_deactivation_approval" {
  name = "account_deactivation_approval"
}

locals {
  dynamodb_maintenance_sfn_content = var.enable_dynamodb_cleanup ? templatefile(
    "${path.module}/templates/dynamodb_cleanup_task.tpl",
    {
      function_arn = module.dynamodb_cleanup.function_arn
  }) : ""
  # list of parallel states to run as part of the ldap object clean up
  # **Note: this list must start with a comma
  additional_cleanup_tasks_internal = var.enable_dynamodb_cleanup ? ",${local.dynamodb_maintenance_sfn_content}" : ""
  additional_cleanup_tasks          = var.additional_cleanup_tasks == "" ? local.additional_cleanup_tasks_internal : "${local.additional_cleanup_tasks_internal}, ${var.additional_cleanup_tasks}"

}

resource "aws_sfn_state_machine" "ldap_maintenance" {
  name     = var.project_name
  role_arn = aws_iam_role.sfn.arn

  definition = templatefile(
    "${path.module}/templates/ldap_maintainer_stepfunction.tpl",
    {
      ldap_query_lambda_name     = module.ldap_query_lambda.function_arn
      manual_approval_timeout    = var.manual_approval_timeout
      slack_notifier_lambda_name = module.slack_notifier.function_name
      additional_cleanup_tasks   = local.additional_cleanup_tasks
  })
}

# cloudwatch event
data "aws_iam_policy_document" "cwe" {
  statement {
    sid = "AllowTriggerSFN"
    actions = [
      "states:StartExecution"
    ]
    resources = [
      aws_sfn_state_machine.ldap_maintenance.id
    ]
  }
}

resource "aws_iam_policy" "cwe" {
  name        = "${var.project_name}-cwe"
  description = "Policy used by the ${var.project_name} Cloudwatch Event"
  policy      = data.aws_iam_policy_document.cwe.json
}

data "aws_iam_policy_document" "cwe_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cwe" {
  name = "${var.project_name}-cwe"

  assume_role_policy = data.aws_iam_policy_document.cwe_trust.json
}

resource "aws_iam_policy_attachment" "cwe" {
  name       = "${var.project_name}-cwe"
  roles      = [aws_iam_role.cwe.name]
  policy_arn = aws_iam_policy.cwe.arn
}

resource "aws_cloudwatch_event_rule" "this" {
  name                = "${var.project_name}-scheduled-trigger"
  description         = "CWE that triggers the ${var.project_name} stepfunction"
  schedule_expression = var.maintenance_schedule
}

resource "aws_cloudwatch_event_target" "this" {
  rule     = aws_cloudwatch_event_rule.this.name
  arn      = aws_sfn_state_machine.ldap_maintenance.id
  input    = "{\"action\": \"query\"}"
  role_arn = aws_iam_role.cwe.arn
}
