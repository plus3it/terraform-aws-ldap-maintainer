module "test_infrastructure" {
  source = "./test_infrastructure"

  create_dynamodb              = var.create_dynamodb_cleanup
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
}

module "ldap_maintainer" {
  source = "../../"

  create_dynamodb_cleanup = var.create_dynamodb_cleanup
  domain_base_dn          = module.test_infrastructure.domain_base_dn
  dynamodb_table_name     = module.test_infrastructure.dynamodb_table_name
  dynamodb_table_arn      = module.test_infrastructure.dynamodb_table_arn
  ldaps_url               = module.test_infrastructure.ldaps_url
  svc_user_dn             = module.test_infrastructure.svc_user_dn
  svc_user_pwd_ssm_key    = module.test_infrastructure.svc_user_pwd_ssm_key
  vpc_id                  = module.test_infrastructure.vpc_id
  slack_channel_id        = var.slack_channel_id
  slack_api_token         = var.slack_api_token
  slack_signing_secret    = var.slack_signing_secret
  filter_prefixes         = var.filter_prefixes
}
