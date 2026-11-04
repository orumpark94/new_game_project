# outputs.tf: 인스턴스·서버 전용 SG·데이터 볼륨 ID와 선택적 공인 IP를 반환합니다.
# ALB 대상 등록과 배포 루트의 서버별 결과 출력에 사용합니다.

output "instance_id" {
  description = "인스턴스 ID"
  value       = aws_instance.this.id
}

output "security_group_id" {
  description = "서버 전용 보안 그룹 ID"
  value       = module.server_security_group.security_group_id
}

output "public_ip" {
  description = "선택적으로 생성한 Elastic IP"
  value       = var.allocate_eip ? aws_eip.this[0].public_ip : null
}

output "data_volume_ids" {
  description = "디바이스명 => 데이터 볼륨 ID"
  value       = { for name, volume in aws_ebs_volume.this : name => volume.id }
}
