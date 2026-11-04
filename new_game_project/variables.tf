# variables.tf: 배포 루트에서 사용할 리전과 Linux AMI 입력값을 정의합니다.
# 입력값은 versions.tf의 Provider 설정과 main.tf의 이미지 선택에 사용됩니다.

variable "aws_region" {
  description = "공개용 프로젝트를 실행할 AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "ami_id" {
  description = ""
  type        = string
  validation {
    condition     = can(regex("^ami-[0-9a-f]{17}$", var.ami_id))
    error_message = "ami-와 17자리 16진수로 구성된 AMI ID를 지정하세요."
  }
}
