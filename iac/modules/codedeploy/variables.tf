variable "environment" {
  type = string
}

variable "resourceName" {
  type = string
}

variable "termination_wait_time_in_minutes" {
  type = string
}
####### Variables for canary Deployment config ##############
variable "deployment_config_option" {
  type        = string
  description = "option for choose which deployment config you want to apply, AllAtOnce value will apply All at once and no canary"
}
variable "time_interval_in_minutes" {
  type = string
}

variable "percentage_canary_deployment" {
  type = string
}
####################
variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

variable "rBlueTargetGroupName" {
  type = string
}

variable "rGreenTargetGroupName" {
  type = string
}

variable "rBluenListenerArn" {
  type = string
}

variable "rGreenListenerArn" {
  type = string
}

variable "taskIamRoleArn" {
  type = string
}
variable "taskIamExecutionRoleArn" {
  type = string
}