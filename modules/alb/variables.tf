# variables.tf: ALB 네트워크·접근 대역·대상 서버·리스너의 입력 형식을 정의합니다.
# 서브넷 수와 포트 구성을 검증하며, 리스너에 인증서를 지정하면 HTTPS를 사용합니다.

variable "name" {
  description = "ALB 이름(영문/숫자/하이픈, 최대 32자)"
  type        = string
}

variable "vpc_id" {
  description = "ALB와 대상 서버가 속한 VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "서로 다른 AZ에 위치한 서브넷 ID 두 개 이상"
  type        = list(string)
  validation {
    condition     = length(distinct(var.subnet_ids)) >= 2
    error_message = "ALB에 서로 다른 서브넷을 최소 두 개 지정하세요. AZ 중복 여부는 별도로 확인해야 합니다."
  }
}

variable "internal" {
  description = "내부 ALB 여부"
  type        = bool
  default     = true
}

variable "client_cidrs" {
  description = "ALB에 접근 가능한 클라이언트 IPv4 CIDR 목록"
  type        = list(string)
  validation {
    condition     = length(var.client_cidrs) > 0 && alltrue([for cidr in var.client_cidrs : can(cidrnetmask(cidr))])
    error_message = "유효한 IPv4 CIDR을 한 개 이상 지정하세요."
  }
}

variable "targets" {
  description = "서버 이름 => 인스턴스 ID/서버 전용 SG ID. 키는 plan 이전에 결정되어야 합니다."
  type = map(object({
    instance_id       = string
    security_group_id = string
  }))
  validation {
    condition     = length(var.targets) > 0
    error_message = "대상 서버를 최소 한 대 지정하세요."
  }
}

variable "listeners" {
  description = "리스너 이름 => 포트/대상 포트 목록/검사 경로. 인증서 지정 시 HTTPS 사용"
  type = map(object({
    port              = number
    target_group_name = string
    target_ports      = list(number)
    health_check_path = optional(string, "/")
    certificate_arn   = optional(string)
  }))
  validation {
    condition = length(var.listeners) > 0 && alltrue([
      for listener in values(var.listeners) :
      listener.port >= 1 && listener.port <= 65535 &&
      length(listener.target_ports) > 0 &&
      length(distinct(listener.target_ports)) == length(listener.target_ports) &&
      alltrue([for port in listener.target_ports : port >= 1 && port <= 65535])
    ])
    error_message = "리스너와 중복 없는 대상 포트를 지정하고, 포트 범위는 1~65535를 사용하세요."
  }
  validation {
    condition     = length(distinct([for listener in values(var.listeners) : listener.port])) == length(var.listeners)
    error_message = "리스너 포트는 중복될 수 없습니다."
  }
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}
