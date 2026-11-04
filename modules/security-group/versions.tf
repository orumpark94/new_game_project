# versions.tf: Security Group 모듈에 필요한 Terraform·AWS Provider 버전 조건을 선언합니다.
# AWS 인증과 리전 설정은 호출부의 Provider에서 상속합니다.

terraform {
  required_version = ">= 1.10, < 2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
