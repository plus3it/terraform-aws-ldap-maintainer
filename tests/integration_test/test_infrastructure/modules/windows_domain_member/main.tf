locals {
  callers_ip = ["${chomp(data.http.ip.body)}/32"]

  specified_cidr_blocks = local.callers_ip
  public_ip             = "${chomp(data.http.ip.body)}/32"
  allow_inbound         = "${compact(distinct(concat(list(local.public_ip), var.additional_ips_allow_inbound)))}"
}

resource "aws_security_group" "this" {
  count = "${var.create_windows_instance ? 1 : 0}"

  name_prefix = "${var.project_name}-sg"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, map("Name", var.project_name))
}

data "http" "ip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group_rule" "rdp" {
  count = "${var.create_windows_instance ? 1 : 0}"

  type        = "ingress"
  from_port   = 3389
  to_port     = 3389
  protocol    = "tcp"
  cidr_blocks = local.allow_inbound

  security_group_id = aws_security_group.this.*.id[count.index]
}

resource "aws_security_group_rule" "out_all" {
  count = "${var.create_windows_instance ? 1 : 0}"

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.this.*.id[count.index]
}

# Windows instance

data "aws_ami" "windows2016" {
  count = "${var.create_windows_instance ? 1 : 0}"

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Base*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "win" {
  count = "${var.create_windows_instance ? 1 : 0}"

  ami                         = data.aws_ami.windows2016.*.id[count.index]
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  vpc_security_group_ids      = [aws_security_group.this.*.id[count.index]]
  subnet_id                   = var.instance_subnet
  associate_public_ip_address = true
  iam_instance_profile        = var.instance_profile
  user_data                   = <<EOF
<powershell>
ADD-WindowsFeature RSAT-Role-Tools
</powershell>
EOF

  tags = merge(var.tags, map("Name", var.project_name))
}

# ssm

locals {
  ssm_document_name = "${replace(var.project_name, "-", "_")}_domain_join"
}

resource "aws_ssm_document" "domain_join" {
  count = "${var.create_windows_instance ? 1 : 0}"

  name          = local.ssm_document_name
  document_type = "Command"

  content = <<DOC
{
        "schemaVersion": "1.0",
        "description": "Configuration to join an instance to the ${var.project_name} domain",
        "runtimeConfig": {
          "aws:domainJoin": {
              "properties": {
                "directoryId": "${var.directoryId}",
                "directoryName": "${var.directoryName}",
                "directoryOU": "${var.directoryOU}",
                "dnsIpAddresses": ${jsonencode(var.dnsIpAddresses)}
              }
          }
        }
}
DOC
}

resource "aws_ssm_association" "this" {
  count = "${var.create_windows_instance ? 1 : 0}"

  name = aws_ssm_document.domain_join.*.name[count.index]

  targets {
    key    = "InstanceIds"
    values = [aws_instance.win.*.id[count.index]]
  }
}
