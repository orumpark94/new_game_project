# server.tf: 서버명별 이미지·사양·서브넷·디스크·공인 IP 사용 여부를 정의합니다.
# main.tf의 EC2 모듈이 이 인벤토리를 for_each로 순회해 서버를 생성합니다.

# 서버명은 for_each 키가 됩니다. / 아래 코드는 더미 코드입니다.
locals {
  servers = {
    demo-app-01 = {
      image                  = "linux"
      subnet                 = "app_a"
      private_ip             = "10.42.10.10"
      instance_type          = "t3.micro"
      root_volume_size       = 30
      data_volumes           = { "/dev/sdf" = { size = 10 } }
      allocate_eip           = false
      ingress_rules          = {}
      egress_rules           = {}
      termination_protection = false
    }


    demo-game-01 = {
      image                  = "linux"
      subnet                 = "app_c"
      private_ip             = "10.42.20.10"
      instance_type          = "t3.micro"
      root_volume_size       = 50
      data_volumes           = { "/dev/sdf" = { size = 60 } }
      allocate_eip           = false
      ingress_rules          = {}
      egress_rules           = {}
      termination_protection = false
    }
  }
}