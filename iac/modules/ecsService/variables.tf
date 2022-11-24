variable "rBlueTargetGroupArn" {
  type    = string
  default = ""
}
variable "environment" {
  type = string
}
variable "public_subnet_ids" {
  type = list(string)
}
##Variables for task def ###
variable "app_port" {
  type = number
}
variable "vpc_cidr" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "cpu" {
  type = number
}
variable "memory" {
  type = number
}
variable "task_name" {
  type = string
}
variable "task_family" {
  type = string
}
variable "task_network_mode" {
  type = string
}
variable "task_requires_compatibilities" {
  type = string
}
variable "serviceName" {
  type = string
}
##Variables for ecs service ###
variable "cluster_id" {
  type = string
}
variable "cluster_name" {
  type = string
}
variable "desired_tasks" {
  type = number
}
variable "max_capacity" {
  type = number
}
variable "ecs_service_ram_target_value" {
  type = number
}
variable "ecs_service_cpu_target_value" {
  type = number
}
variable "service_launch_type" {
  type = string
}
variable "enable_ecs_managed_tags" {
  type = string
}
variable "assign_public_ip" {
  type = bool
}
variable "repo_url" {
  type = string
}
variable "alb_sg" {
  type = string
}
