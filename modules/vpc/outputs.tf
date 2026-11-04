# outputs.tf: 생성한 VPC·서브넷·라우팅 테이블의 ID를 호출부에 제공합니다.
# 서브넷 ID는 이름별 맵으로 반환해 EC2와 ALB의 네트워크 선택에 사용합니다.

output "vpc_id" {
  description = "생성한 VPC ID"
  value       = aws_vpc.this.id
}

output "subnet_ids" {
  description = "서브넷 이름 => ID"
  value       = { for name, subnet in aws_subnet.this : name => subnet.id }
}

output "route_table_id" {
  description = "모든 서브넷이 공유하는 라우팅 테이블 ID"
  value       = aws_route_table.this.id
}
