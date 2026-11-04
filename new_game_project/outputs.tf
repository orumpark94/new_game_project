# outputs.tf: 생성한 서버의 인스턴스·보안 그룹·디스크 정보와 ALB DNS를 출력합니다.
# EC2·ALB 모듈의 결과를 서버명과 ALB 이름을 키로 묶어 제공합니다.

output "servers" {
  description = "서버 이름별 인스턴스/보안 그룹/추가 디스크 정보"
  value = {
    for name, server in module.EC2 : name => {
      instance_id       = server.instance_id
      security_group_id = server.security_group_id
      data_volume_ids   = server.data_volume_ids
      public_ip         = server.public_ip
    }
  }
}

output "alb_dns" {
  description = "ALB 이름별 DNS 주소"
  value       = { for name, alb in module.ALB : name => alb.dns_name }
}
