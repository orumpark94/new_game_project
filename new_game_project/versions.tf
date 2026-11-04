# versions.tf: 배포 루트의 Terraform·AWS Provider 버전 조건과 AWS 설정을 정의합니다.
# 리전과 공통 태그를 설정하며, 인증 정보는 외부 프로파일이나 역할을 사용합니다.

terraform {
  required_version = ">= 1.10, < 2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project   = "new-game-project"
      ManagedBy = "Terraform"
    }
  }
}
