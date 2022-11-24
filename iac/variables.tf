/*Common Vars*/
variable "environment" {
  type = string
}
variable "region" {
  type = string
}
variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}
/***********************/
/*ECS Cluster Variables*/
variable "clusterName" {
  type = string
}
variable "log_group_retention_in_days" {
  type = number
}
variable "container_insights" {
  type = string
}
variable "repository_owner" {
  type = string
}