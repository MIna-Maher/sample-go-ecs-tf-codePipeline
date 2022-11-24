
variable "environment" {
  type = string
}
variable "serviceName" {
  type = string
}


#################Codebuild vars###############################
#variable "codeBuildProject_name" {
#  type = string
#}


variable "codebuild_compute_type" {
  type = string
}

variable "coudebuild_image" {
  type = string
}

variable "codebuid_env_type" {
  type = string
}

#################### GitHub Token and Codepipeline configs###########################
variable "GitHubToken" {
  type = string
}
variable "repository_name" {
  type = string
}
variable "repository_branch" {
  type = string
}
variable "repository_owner" {
  type = string
}

#variable "codepipeline_role_arn" {
#  type = string
#}

variable "buildspec_lint_dir" {
  type    = string
  default = "./buildspec-lint.yml"
}

variable "webhook_event" {
  type    = string
  default = "push"
  #can be push,release
}
variable "webhook_filter_json_path" {
  type    = string
  default = "$.ref"
  # for release -> $.action
  # for push -> $.ref
}
variable "webhook_filter_match_equals" {
  type    = string
  default = "refs/heads/{Branch}"
  # for release -> published
  # for push -> refs/heads/{Branch}
}
variable "codedeploy_role_arn" {
  type = string
}
variable "codedeploy_applicationname" {
  type = string
}
variable "codedeploy_groupname" {
  type = string
}