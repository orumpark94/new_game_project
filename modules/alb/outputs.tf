# outputs.tf: ALB DNS·보안 그룹 ID·리스너별 대상 그룹 ARN을 반환합니다.
# 배포 루트에서 ALB 접근 주소와 연결 결과를 확인할 때 사용합니다.

output "dns_name" {
  description = "ALB DNS 이름"
  value       = aws_lb.this.dns_name
}

output "security_group_id" {
  description = "ALB 보안 그룹 ID"
  value       = module.security_group.security_group_id
}

output "target_group_arns" {
  description = "리스너 이름 => 대상 그룹 ARN"
  value       = { for name, group in aws_lb_target_group.this : name => group.arn }
}
