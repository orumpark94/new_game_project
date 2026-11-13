# 공유 SG의 규칙과 적용 대상을 함께 검토할 수 있도록 정의합니다.
locals {
  shared_security_groups = {
    game_service = {
      target_servers = ["demo-game-01"]
      ingress_rules = {
        demo_game_tcp = {
          from_port = 30000
          to_port   = 30000
          protocol  = "tcp"
          cidr_ipv4 = "198.51.100.0/24"
        }
      }
      egress_rules = {}
    }
  }

  shared_sg_keys_by_server = {
    for name in keys(local.servers) : name => [
      for group_key, group in local.shared_security_groups : group_key
      if contains(group.target_servers, name)
    ]
  }
}

# 없는 서버 이름을 적으면 조용히 누락되지 않고 계획에서 실패합니다.
resource "terraform_data" "shared_sg_targets" {
  lifecycle {
    precondition {
      condition = alltrue(flatten([
        for group in values(local.shared_security_groups) : [
          for server_name in group.target_servers : contains(keys(local.servers), server_name)
        ]
      ]))
      error_message = "공유 SG의 target_servers에는 server.tf에 정의된 서버 이름만 사용할 수 있습니다."
    }
  }
}

module "shared_SG" {
  for_each = local.shared_security_groups
  source   = "../modules/security-group"

  name          = "new-game-${each.key}"
  vpc_id        = module.vpc.vpc_id
  ingress_rules = each.value.ingress_rules
  egress_rules  = each.value.egress_rules
}
