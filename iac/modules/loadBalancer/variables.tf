variable "use_ssl" {
  type = string
}
variable "environment" {
  type = string
}
variable "serviceName" {
  type = string
}
variable "alb_listener_domain" {
  type = string
}
variable "aws_lb_internal" {
  type = bool
}
variable "load_balancer_type" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "vpc_id" {
  type = string
}
variable "vpc_cidr" {
  type = string
}
variable "health_check_path" {
  type = string
}
variable "app_port" {
  type = number
}
variable "app_temp_port" {
  type = string
}