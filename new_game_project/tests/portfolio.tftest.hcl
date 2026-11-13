mock_provider "aws" {}

variables {
  aws_region = "ap-northeast-2"
  ami_id     = "ami-0123456789abcdef0"
}

run "explicit_policy_and_traffic_membership" {
  command = plan

  assert {
    condition     = length(module.EC2) == 2
    error_message = "두 예제 서버가 모두 EC2 모듈에 전달되어야 합니다."
  }

  assert {
    condition     = length(local.shared_sg_keys_by_server["demo-app-01"]) == 0 && toset(local.shared_sg_keys_by_server["demo-game-01"]) == toset(["game_service"])
    error_message = "게임용 공유 SG는 demo-game-01에만 지정되어야 합니다."
  }

  assert {
    condition     = toset(keys(local.alb_targets["demo_web"])) == toset(["demo-app-01"])
    error_message = "ALB 대상에는 demo-app-01만 등록되어야 합니다."
  }

  assert {
    condition     = local.servers["demo-app-01"].subnet != local.servers["demo-game-01"].subnet
    error_message = "두 예제 서버는 서로 다른 서브넷을 사용해야 합니다."
  }
}
