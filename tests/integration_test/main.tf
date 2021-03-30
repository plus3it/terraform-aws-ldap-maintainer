module "test_infrastructure" {
  source = "./test_infrastructure"

  enable_dynamodb              = var.enable_dynamodb_cleanup
  project_name                 = var.project_name
  certificate_arn              = var.certificate_arn
  target_zone_name             = var.target_zone_name
  directory_name               = var.directory_name
  create_windows_instance      = var.create_windows_instance
  key_pair_name                = var.key_pair_name
  additional_ips_allow_inbound = var.additional_ips_allow_inbound
  instance_profile             = var.instance_profile
  filter_prefixes              = var.filter_prefixes
  additional_test_users        = var.additional_test_users
  python_ldap_layer_arn        = module.ldap_maintainer.python_ldap_layer_arn
}

module "ldap_maintainer" {
  source = "../../"

  domain_base_dn       = module.test_infrastructure.domain_base_dn
  dynamodb_table_name  = module.test_infrastructure.dynamodb_table_name
  dynamodb_table_arn   = module.test_infrastructure.dynamodb_table_arn
  ldaps_url            = module.test_infrastructure.ldaps_url
  svc_user_dn          = module.test_infrastructure.svc_user_dn
  svc_user_pwd_ssm_key = module.test_infrastructure.svc_user_pwd_ssm_key
  vpc_id               = module.test_infrastructure.vpc_id

  days_since_pwdlastset = 1
  log_level             = "Debug"

  enable_dynamodb_cleanup = var.enable_dynamodb_cleanup
  hands_off_accounts      = var.hands_off_accounts
  manual_approval_timeout = var.manual_approval_timeout
  project_name            = var.project_name
  slack_channel_id        = var.slack_channel_id
  slack_api_token         = var.slack_api_token
  slack_signing_secret    = var.slack_signing_secret
}
