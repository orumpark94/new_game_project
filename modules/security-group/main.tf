# main.tf: 보안 그룹과 이름별 인바운드·아웃바운드 규칙을 생성합니다.
# 각 규칙은 CIDR 또는 다른 SG를 참조하며, 규칙명을 for_each 키로 사용합니다.

resource "aws_security_group" "this" {
  name        = var.name
  description = "Terraform portfolio security group"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = var.name })
}

# 규칙 이름을 for_each 키로 사용해 다른 규칙의 삭제/추가에 영향을 받지 않도록 합니다.
resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = var.ingress_rules

  security_group_id            = aws_security_group.this.id
  description                  = each.key
  ip_protocol                  = each.value.protocol
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  cidr_ipv4                    = each.value.cidr_ipv4
  referenced_security_group_id = each.value.source_sg
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = var.egress_rules

  security_group_id            = aws_security_group.this.id
  description                  = each.key
  ip_protocol                  = each.value.protocol
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  cidr_ipv4                    = each.value.cidr_ipv4
  referenced_security_group_id = each.value.source_sg
}
