# Networking

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  private_subnet_tags = {
    "Network" = "Private"
  }

  public_subnet_tags = {
    "Network" = "Public"
  }

  enable_dhcp_options              = true
  dhcp_options_domain_name         = var.directory_name
  dhcp_options_domain_name_servers = tolist(aws_directory_service_directory.test.dns_ip_addresses)

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = var.tags
}

# SimpleAD

resource "random_string" "password" {
  length  = 16
  special = true
}

resource "aws_directory_service_directory" "test" {
  name     = var.directory_name
  password = random_string.password.result
  size     = var.size

  vpc_settings {
    vpc_id     = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets
  }

  tags = var.tags
}

resource "aws_ssm_parameter" "simplead_password" {
  name        = "/simplead/${var.directory_name}"
  description = "Password for ${var.directory_name} Administrator account"
  type        = "SecureString"
  value       = random_string.password.result
}

# DNS

data "aws_route53_zone" "selected" {
  name         = var.target_zone_name
  private_zone = true
}

resource "aws_route53_record" "ad" {
  zone_id = data.aws_route53_zone.selected.id
  name    = var.directory_name
  type    = "A"
  ttl     = 300
  records = tolist(aws_directory_service_directory.test.dns_ip_addresses)
}

# LDAPS endpoint

resource "aws_route53_record" "ldaps" {
  zone_id = data.aws_route53_zone.selected.id
  name    = "ldaps.${var.directory_name}"
  type    = "A"

  alias {
    name                   = aws_lb.ldaps.dns_name
    zone_id                = aws_lb.ldaps.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb" "ldaps" {
  name               = "${var.project_name}-ldaps"
  internal           = true
  load_balancer_type = "network"
  subnets            = module.vpc.private_subnets

  tags = var.tags
}

resource "aws_lb_target_group" "ldaps" {
  name        = var.project_name
  port        = 389
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "ldaps" {
  load_balancer_arn = aws_lb.ldaps.arn
  port              = 636
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ldaps.arn
  }
}

resource "aws_lb_target_group_attachment" "ldaps_ip" {
  count            = length(var.private_subnet_cidrs)
  target_group_arn = aws_lb_target_group.ldaps.arn
  target_id        = tolist(aws_directory_service_directory.test.dns_ip_addresses)[count.index]
}

# windows instance to manage AD
module "win_ad_mgmt" {
  source = "./modules/windows_domain_member"

  create_windows_instance      = var.create_windows_instance
  vpc_id                       = module.vpc.vpc_id
  instance_subnet              = module.vpc.public_subnets[0]
  key_pair_name                = var.key_pair_name
  additional_ips_allow_inbound = var.additional_ips_allow_inbound
  instance_profile             = var.instance_profile

  directoryId    = aws_directory_service_directory.test.id
  directoryName  = var.directory_name
  directoryOU    = local.dn
  dnsIpAddresses = tolist(aws_directory_service_directory.test.dns_ip_addresses)
}


# dynamodb
resource "aws_dynamodb_table" "test_table" {
  count = var.create_dynamodb ? 1 : 0

  name           = var.project_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "account_name"

  attribute {
    name = "account_name"
    type = "S"
  }

  tags = merge(var.tags, map("Name", var.project_name))
}


locals {
  test_users = [
    "Grace Ogden",
    "Christopher Morgan",
    "Theresa Clarkson",
    "Grace Baker",
    "Justin Dickens",
    "Adam Bond",
    "Taddy Mason",
    "John Terry",
    "William Paige",
    "Stephanie Buckland",
    "Elizabeth Mathis"
  ]

  distro_emails_0 = flatten([
    for name in chunklist(local.test_users, 5)[0] : [
      formatlist("%s@email.com", join(".", split(" ", name)))
    ]
  ])

  distro_emails_1 = flatten([
    for name in chunklist(local.test_users, 5)[0] : [
      formatlist("%s@email.com", join(".", split(" ", name)))
    ]
  ])

  email_object = {
    "Distro1" : local.distro_emails_0,
    "Distro2" : local.distro_emails_1
  }

  distro_list = flatten([
    for distro, emails in local.email_object : [
      "\"${distro}\": {\"L\": [ ${join(",", formatlist("{\"S\": \"%s\"}", emails))} ]}"
    ]
  ])
  distro_list_string = join(",", local.distro_list)
}

data "template_file" "test" {
  count = var.create_dynamodb ? 1 : 0

  template = "${file("${path.module}/table_layout.json.tpl")}"
  vars = {
    account_name = "test123"
    distro_list  = "${local.distro_list_string}"
  }
}

resource "aws_dynamodb_table_item" "email_distro" {
  count = var.create_dynamodb ? 1 : 0

  table_name = aws_dynamodb_table.test_table[count.index].name
  hash_key   = aws_dynamodb_table.test_table[count.index].hash_key

  item = data.template_file.test[count.index].rendered
}

# lambda function to populate ldap
# necessary b/c our LDAPS endpoint is only accessible from inside one of our VPCs
locals {
  dn_list      = split(".", var.directory_name)
  dn_formatted = formatlist("DC=%s", local.dn_list)
  dn           = join(",", local.dn_formatted)
}

module "populate_ldap" {
  source = "./modules/lambda/populate_ldap"

  ldaps_url      = "ldaps://${aws_lb.ldaps.dns_name}"
  domain_base_dn = local.dn
  svc_user_dn    = "CN=Administrator,CN=Users,${local.dn}"
  svc_user_pwd   = random_string.password.result
  vpc_id         = module.vpc.vpc_id
  test_users     = local.test_users
}
