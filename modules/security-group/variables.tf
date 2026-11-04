# variables.tf: 보안 그룹 이름·VPC·접근 규칙·태그의 입력 형식을 정의합니다.
# 각 규칙에서 CIDR과 SG 참조 중 정확히 하나만 지정하도록 검증합니다.

variable "name" {
  description = "보안 그룹 이름"
  type        = string
}

variable "vpc_id" {
  description = "보안 그룹을 생성할 VPC ID"
  type        = string
}

variable "ingress_rules" {
  description = "규칙 이름 => 포트/프로토콜/대상. source_sg는 출발지 SG를 뜻합니다."
  type = map(object({
    from_port = optional(number)
    to_port   = optional(number)
    protocol  = string
    cidr_ipv4 = optional(string)
    source_sg = optional(string)
  }))
  default = {}
  validation {
    condition = alltrue([
      for rule in values(var.ingress_rules) :
      (rule.cidr_ipv4 == null) != (rule.source_sg == null)
    ])
    error_message = "각 규칙은 cidr_ipv4 또는 source_sg 중 정확히 하나를 지정해야 합니다."
  }
}

variable "egress_rules" {
  description = "규칙 이름 => 포트/프로토콜/대상. source_sg는 목적지 SG를 뜻합니다."
  type = map(object({
    from_port = optional(number)
    to_port   = optional(number)
    protocol  = string
    cidr_ipv4 = optional(string)
    source_sg = optional(string)
  }))
  default = {}
  validation {
    condition = alltrue([
      for rule in values(var.egress_rules) :
      (rule.cidr_ipv4 == null) != (rule.source_sg == null)
    ])
    error_message = "각 규칙은 cidr_ipv4 또는 source_sg 중 정확히 하나를 지정해야 합니다."
  }
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}
