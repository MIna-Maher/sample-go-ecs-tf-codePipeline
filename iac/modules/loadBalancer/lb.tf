###############################
## Terraform Data ##
## Cross public subnets IDS
###############################
## Terraform Locals ##
## two fields indicating is that the ssl should be used or not
###############################
locals {
  useSSL       = var.use_ssl == "true" ? true : false
}
# Find a certificate that is issued
data "aws_acm_certificate" "certificate" {
  count    = local.useSSL ? 1 : 0
  domain   = var.alb_listener_domain
  statuses = ["ISSUED"]
}
data "aws_caller_identity" "current" {}
###############################
## Terraform Resource ##
## ALB 
## ALB Blue Target Group
## ALB Green Target Group
## ALB Listeners
###############################
resource "aws_alb" "main" {
  load_balancer_type = var.load_balancer_type
  subnets            = var.subnet_ids
  security_groups    = [aws_security_group.lb.id]
  idle_timeout       = 300
  tags               = merge({ Name = format("%s-%s-lb", var.environment, var.serviceName) })
  
}

resource "aws_alb_target_group" "awsBlueTargetGroup" {
  name        = format("%s-%s-alb-tg-blue", var.environment, var.serviceName)
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  tags        = merge({ Name = format("%s-%s-alb-tg-blue", var.environment, var.serviceName) })

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "10"
    interval            = "60"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "50"
    path                = var.health_check_path
  }
}
####
resource "aws_alb_target_group" "awsGreenTargetGroup" {
  name        = format("%s-%s-alb-tg-green", var.environment, var.serviceName)
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  tags        = merge({ Name = format("%s-%s-alb-tg-green", var.environment, var.serviceName) })

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "10"
    interval            = "60"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "50"
    path                = var.health_check_path
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "awsBlueTargetGroupListener" {
  load_balancer_arn = aws_alb.main.id
  port              = local.useSSL ? "443" : var.app_port
  protocol          =  local.useSSL ? "HTTPS" : "HTTP"
  ##### Note incase of swithing from https to http, ssl_policy cannot be deleted, so It has to be removed manally from
  ## Console and run the code with http :https://github.com/hashicorp/terraform-provider-aws/issues/10961

  ssl_policy        = local.useSSL ? "ELBSecurityPolicy-TLS-1-2-2017-01" : null
  certificate_arn   = local.useSSL ? data.aws_acm_certificate.certificate[0].arn : null

  default_action {
    target_group_arn = aws_alb_target_group.awsBlueTargetGroup.id
    type             = "forward"
  }
  lifecycle {
    ignore_changes = [
      default_action
    ]
  }
}
# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "awsGreenTargetGroupListener" {
  load_balancer_arn = aws_alb.main.id
  port              = local.useSSL ? "8443" : var.app_temp_port
  protocol          =  local.useSSL ? "HTTPS" : "HTTP"
   ##### Note incase of swithing from https to http, ssl_policy cannot be deleted, so It has to be removed manally from
  ## Console and run the code with http :https://github.com/hashicorp/terraform-provider-aws/issues/10961
  ssl_policy        = local.useSSL ? "ELBSecurityPolicy-TLS-1-2-2017-01" : null
  certificate_arn   = local.useSSL ? data.aws_acm_certificate.certificate[0].arn : null

  default_action {
    target_group_arn = aws_alb_target_group.awsGreenTargetGroup.id
    type             = "forward"
  }

  lifecycle {
    ignore_changes = [
      default_action
    ]
  }
}


#####################
resource "aws_lb_listener" "ssl_redirect" {
  count = local.useSSL ? 1 : 0
  load_balancer_arn = aws_alb.main.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
#################
#################
## ALB SG####

resource "aws_security_group" "lb" {
  name        = format("%s_%s-lb-securitygroup", var.environment, var.serviceName)
  description = "controls access to the LB"
  vpc_id      = var.vpc_id

  tags = merge({ Name = format("%s-%s-lb-securitygroup", var.environment, var.serviceName) })
  ingress {
    from_port   = local.useSSL ? "443" : var.app_port
    to_port     = local.useSSL ? "443" : var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = local.useSSL ? "443" : var.app_temp_port
    to_port     = local.useSSL ? "443" : var.app_temp_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }



  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}