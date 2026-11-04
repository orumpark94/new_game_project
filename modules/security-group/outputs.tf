# outputs.tf: 생성한 보안 그룹 ID를 호출부에 제공합니다.
# EC2의 공통·서버 전용 SG 부착과 ALB의 백엔드 연결에 사용합니다.

output "security_group_id" {
  description = "생성한 보안 그룹 ID"
  value       = aws_security_group.this.id
}
