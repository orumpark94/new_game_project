# alb.tf: ALB별 서브넷·접근 대역·대상 서버·리스너를 정의하고 ALB 모듈을 호출합니다.
# server.tf의 서버명을 기준으로 EC2 출력값을 연결하며, 백엔드 SG 규칙은 모듈이 생성합니다.


locals {
  albs = {
    demo_web = { # 더미 ALB 생성
      name           = "new-game-web-alb"
      subnet_keys    = ["app_a", "app_c"]
      internal       = false
      client_cidrs   = ["192.0.2.0/24"]
      target_servers = ["demo-app-01"]
      listeners = {
        http = {
          port              = 80
          target_group_name = "new-game-web-http"
          target_ports      = [8080]
          health_check_path = "/"
        }
      }
    }
  }

  alb_targets = {
    for alb_key, alb in local.albs : alb_key => {
      for name in alb.target_servers : name => {
        instance_id       = module.EC2[name].instance_id
        security_group_id = module.EC2[name].security_group_id
      }
    }
  }
}

module "ALB" {
  for_each = local.albs
  source   = "../modules/alb"

  name         = each.value.name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = [for name in each.value.subnet_keys : module.vpc.subnet_ids[name]]
  internal     = each.value.internal
  client_cidrs = each.value.client_cidrs
  listeners    = each.value.listeners

  targets = local.alb_targets[each.key]

  # IGW와 라우팅 구성이 끝난 뒤 인터넷용 ALB를 생성합니다.
  depends_on = [module.vpc]
}
