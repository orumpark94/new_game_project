# variables.tf: 서버 사양·네트워크·보안 규칙·디스크·초기화 스크립트 입력을 정의합니다.
# 서버별 차이는 입력값으로 받고, 공통 생성 절차는 main.tf에 유지합니다.

variable "name" {
  description = "서버 이름"
  type        = string
}

variable "vpc_id" {
  description = "서버 보안 그룹을 생성할 VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "배치할 서브넷 ID"
  type        = string
}

variable "private_ip" {
  description = "서브넷에 속하는 고정 사설 IPv4 주소"
  type        = string
}

variable "ami_id" {
  description = "대상 리전에서 사용 가능한 실제 AMI ID"
  type        = string
}

variable "instance_type" {
  description = "인스턴스 유형"
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "루트 볼륨 크기(GiB). AMI의 최소 볼륨 크기 이상이어야 합니다."
  type        = number
  default     = 30
  validation {
    condition     = var.root_volume_size >= 8 && floor(var.root_volume_size) == var.root_volume_size
    error_message = "루트 볼륨은 8GiB 이상의 정수로 지정하세요."
  }
}

variable "data_volumes" {
  description = "디바이스명 => EBS 크기(GiB). OS 내 포맷/마운트는 별도 작업입니다."
  type        = map(object({ size = number }))
  default     = {}
  validation {
    condition     = alltrue([for volume in values(var.data_volumes) : volume.size > 0 && floor(volume.size) == volume.size])
    error_message = "데이터 볼륨 크기는 양의 정수여야 합니다."
  }
}

variable "common_security_group_ids" {
  description = "공통/OS별 보안 그룹 ID. 서버 전용 SG와 합쳐 부착합니다."
  type        = list(string)
  default     = []
}

variable "ingress_rules" {
  description = "서버 전용 ingress 규칙. 대상 검증은 하위 security-group 모듈에서 수행합니다."
  type = map(object({
    from_port = optional(number)
    to_port   = optional(number)
    protocol  = string
    cidr_ipv4 = optional(string)
    source_sg = optional(string)
  }))
  default = {}
}

variable "egress_rules" {
  description = "서버 전용 egress 규칙. 대상 검증은 하위 security-group 모듈에서 수행합니다."
  type = map(object({
    from_port = optional(number)
    to_port   = optional(number)
    protocol  = string
    cidr_ipv4 = optional(string)
    source_sg = optional(string)
  }))
  default = {}
}

variable "allocate_eip" {
  description = "명시적으로 선택한 서버에만 Elastic IP 생성"
  type        = bool
  default     = false
}

variable "termination_protection" {
  description = "API 종료 방지. 실습 예제는 정리를 위해 false로 전달합니다."
  type        = bool
  default     = true
}

variable "key_name" {
  description = "선택적 EC2 키 페어 이름. 개인 키는 입력하거나 저장하지 않습니다."
  type        = string
  default     = null
}

variable "user_data" {
  description = "비밀값을 포함하지 않는 첫 부팅 초기화 스크립트"
  type        = string
  default     = null
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}
