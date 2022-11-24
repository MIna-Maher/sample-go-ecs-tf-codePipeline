###############################
## Terraform Resource ##
## ECS Service Security Group
###############################
resource "aws_security_group" "service_sg_alb" {
  vpc_id = var.vpc_id
  name   = format("%s_%s-sg", var.environment, var.serviceName)
  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [var.alb_sg]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge({ Name = format("%s_%s-sg", var.environment, var.serviceName) })
}
