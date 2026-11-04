# main.tf: EC2와 서버 전용 SG·암호화 EBS·선택적 EIP를 함께 구성합니다.
# 호출부가 지정한 사양과 공통 SG를 적용하고, user_data로 초기 설정을 전달합니다.

module "server_security_group" {
  source = "../security-group"

  name          = "${var.name}-server"
  vpc_id        = var.vpc_id
  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules
  tags          = var.tags
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  private_ip                  = var.private_ip
  key_name                    = var.key_name
  associate_public_ip_address = false
  vpc_security_group_ids      = concat(var.common_security_group_ids, [module.server_security_group.security_group_id])
  user_data                   = var.user_data
  disable_api_termination     = var.termination_protection

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
    tags        = merge(var.tags, { Name = "${var.name}-root" })
  }

  tags = merge(var.tags, { Name = var.name })
}

# 디바이스명을 고정 키로 사용합니다. 변경 시 볼륨 교체 가능성을 plan에서 확인해야 합니다.
resource "aws_ebs_volume" "this" {
  for_each = var.data_volumes

  availability_zone = aws_instance.this.availability_zone
  size              = each.value.size
  type              = "gp3"
  encrypted         = true
  tags              = merge(var.tags, { Name = "${var.name}-${each.key}" })
}

resource "aws_volume_attachment" "this" {
  for_each = var.data_volumes

  device_name = each.key
  volume_id   = aws_ebs_volume.this[each.key].id
  instance_id = aws_instance.this.id
}

resource "aws_eip" "this" {
  count = var.allocate_eip ? 1 : 0

  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.name}-eip" })
}

resource "aws_eip_association" "this" {
  count = var.allocate_eip ? 1 : 0

  instance_id   = aws_instance.this.id
  allocation_id = aws_eip.this[0].id
}
