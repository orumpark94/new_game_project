# sg.tf: 여러 서버가 함께 사용할 공유 보안 그룹의 규칙과 모듈 호출을 정의합니다.
# OS 공통·공유·서버 전용 보안 그룹은 main.tf의 EC2 모듈에서 함께 부착합니다.

# 여러 서버에 부착할 수 있는 공유 보안 그룹입니다.
# 서버 전용 SG는 EC2 모듈, ALB 연결 규칙은 ALB 모듈이 생성합니다.
locals {
  shared_security_groups = {
    Demo-GAME-SG = {
      sg_name        = "Demo-GAME-SG"
      sg_description = "Demo-GAME-SG Server common fw policy"
      target_server  = ["AS-GAME-1-1", "AS-GAME-1-2", "AS-GAME-1-3"]
      ingress_rules = {
        API-1-1    = { from_port = 30000, to_port = 30000, protocol = "tcp", cidr = "10.10.10.10/32" }
      }
      egress_rules = {
        LOG-1-2_20000     = { from_port = 20000, to_port = 20000, protocol = "tcp", cidr = "20.20.20.20/32" }
      }
    }

    Demo-ELK-SG = {
      sg_name        = "Demo-ELK-SG"
      sg_description = "ELK nodes common fw policy"
      target_server  = ["AS-ELK-NODE-1", "AS-ELK-NODE-2"]
      ingress_rules = {
        Gateway_10000    = { from_port = 10000, to_port = 10000, protocol = "tcp", cidr = "30.30.30.30/32" }
      }
      egress_rules = {
        ELK-NODE = { from_port = 9200, to_port = 9200, protocol = "tcp", cidr = "30.30.30.30/32" }
      }
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
