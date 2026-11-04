# variables.tf: VPC 이름·CIDR·서브넷 인벤토리·공통 태그의 입력 형식을 정의합니다.
# 호출부에서 전달한 서브넷 이름이 리소스 생성과 출력값의 식별 키가 됩니다.

variable "name" {
  description = "VPC 및 관련 리소스의 이름 접두사"
  type        = string
}

variable "cidr_block" {
  description = "VPC IPv4 CIDR"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.cidr_block))
    error_message = "유효한 IPv4 CIDR을 입력하세요."
  }
}

variable "subnets" {
  description = "서브넷 이름을 키로 갖는 네트워크 인벤토리"
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  validation {
    condition     = length(var.subnets) > 0 && alltrue([for subnet in values(var.subnets) : can(cidrnetmask(subnet.cidr_block))])
    error_message = "IPv4 CIDR을 갖는 서브넷을 한 개 이상 입력하세요."
  }
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}
