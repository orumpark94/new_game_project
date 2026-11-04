# main.tf: ALB·리스너·대상 그룹·서버 등록과 백엔드 SG 연결 규칙을 생성합니다.
# 대상 등록은 리스너별로 구성하고, 같은 서버·포트의 SG 규칙은 한 번만 생성합니다.

locals {
  # 리스너 x 서버 x 포트 조합을 정적인 이름 키로 전개합니다.
  attachments = merge([
    for listener_name, listener in var.listeners : {
      for pair in setproduct(keys(var.targets), listener.target_ports) :
      "${listener_name}-${pair[0]}-${pair[1]}" => {
        listener_name = listener_name
        instance_id   = var.targets[pair[0]].instance_id
        port          = pair[1]
      }
    }
  ]...)

  # 여러 리스너가 같은 백엔드 포트를 사용해도 SG 규칙은 서버/포트별 한 번만 만듭니다.
  connections = merge([
    for target_name, target in var.targets : {
      for port in toset(flatten([for listener in values(var.listeners) : listener.target_ports])) :
      "${target_name}-${port}" => {
        security_group_id = target.security_group_id
        port              = port
      }
    }
  ]...)

  client_rules = merge([
    for listener_name, listener in var.listeners : {
      for index, cidr in var.client_cidrs : "${listener_name}-client-${index}" => {
        from_port = listener.port
        to_port   = listener.port
        protocol  = "tcp"
        cidr_ipv4 = cidr
      }
    }
  ]...)
}

module "security_group" {
  source = "../security-group"

  name          = "${var.name}-alb"
  vpc_id        = var.vpc_id
  ingress_rules = local.client_rules
  tags          = var.tags
}

resource "aws_lb" "this" {
  name               = var.name
  load_balancer_type = "application"
  internal           = var.internal
  security_groups    = [module.security_group.security_group_id]
  subnets            = var.subnet_ids
  tags               = var.tags
}

resource "aws_lb_target_group" "this" {
  for_each = var.listeners

  name        = each.value.target_group_name
  port        = each.value.target_ports[0]
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
  tags        = var.tags

  health_check {
    path     = each.value.health_check_path
    port     = "traffic-port"
    protocol = "HTTP"
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = local.attachments

  target_group_arn = aws_lb_target_group.this[each.value.listener_name].arn
  target_id        = each.value.instance_id
  port             = each.value.port
}

resource "aws_lb_listener" "this" {
  for_each = var.listeners

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.certificate_arn == null ? "HTTP" : "HTTPS"
  certificate_arn   = each.value.certificate_arn
  ssl_policy        = each.value.certificate_arn == null ? null : "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }
}

resource "aws_vpc_security_group_egress_rule" "to_target" {
  for_each = local.connections

  security_group_id            = module.security_group.security_group_id
  description                  = "to-${each.key}"
  from_port                    = each.value.port
  to_port                      = each.value.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = each.value.security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "from_alb" {
  for_each = local.connections

  security_group_id            = each.value.security_group_id
  description                  = "from-${var.name}-${each.key}"
  from_port                    = each.value.port
  to_port                      = each.value.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = module.security_group.security_group_id
}
