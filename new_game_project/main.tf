# main.tf: VPC와 OS 공통 보안 그룹을 구성하고, 서버별 EC2 모듈을 호출합니다.
# server.tf의 서버 인벤토리(inventory)와 sg.tf의 공유 보안 그룹을 연결합니다.


module "vpc" {
  source = "../modules/vpc"

  name       = "new-game-project"
  cidr_block = "10.42.0.0/16"
  subnets = {
    app_a = { cidr_block = "10.42.10.0/24", availability_zone = "${var.aws_region}a" }
    app_c = { cidr_block = "10.42.20.0/24", availability_zone = "${var.aws_region}c" }
  }
}

module "Linux_Common" {
  source = "../modules/security-group"

  name   = "new-game-linux-common"
  vpc_id = module.vpc.vpc_id
  # 공통 OS 정책을 넣는 위치입니다. 기본적으로 추가 허용 규칙은 없습니다.
}

locals {
  images = { linux = var.ami_id }
}

module "EC2" {
  for_each = local.servers
  source   = "../modules/ec2"

  name             = each.key
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.subnet_ids[each.value.subnet]
  ami_id           = local.images[each.value.image]
  private_ip       = each.value.private_ip
  instance_type    = each.value.instance_type
  root_volume_size = each.value.root_volume_size
  data_volumes     = each.value.data_volumes
  allocate_eip     = each.value.allocate_eip
  ingress_rules    = each.value.ingress_rules
  egress_rules     = each.value.egress_rules
  common_security_group_ids = concat(
    [module.Linux_Common.security_group_id],
    [for group_key in local.shared_sg_keys_by_server[each.key] : module.shared_SG[group_key].security_group_id]
  )
  termination_protection = each.value.termination_protection

  user_data = templatefile("${path.module}/templates/linux_init.sh.tpl", {
    hostname = each.key
  })
}
