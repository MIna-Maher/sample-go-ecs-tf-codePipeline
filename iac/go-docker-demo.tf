provider "aws" {
  region = var.region
}
data "aws_vpc" "vpc" {
  id = var.vpc_id
}
data "aws_ssm_parameter" "GitHubToken" {
  name            = "GitHubToken"
  with_decryption = "true"
  #####Default for with_decryption is true
}
provider "github" {
  token = data.aws_ssm_parameter.GitHubToken.value
  owner = var.repository_owner
}
## Create ecs cluster

module "ecsCluster" {
  source = "./modules/ecsCluster"

  environment                 = var.environment
  clusterName                 = var.clusterName
  log_group_retention_in_days = var.log_group_retention_in_days
  container_insights          = var.container_insights
}
module "ecrRepUIService" {
  source                   = "./modules/ecrRepo"
  environment              = var.environment
  serviceName              = "go-docker-demo"
  scan_on_push             = false
  image_tag_mutability     = "MUTABLE"
  encryption_type          = "AES256"
  image_expiration_in_days = 30
  image_tag_status         = "untagged"
}

module "albUIService" {
  source              = "./modules/loadBalancer"
  use_ssl             = "false"
  aws_lb_internal     = false
  load_balancer_type  = "application"
  health_check_path   = "/"
  alb_listener_domain = "mina.com"
  vpc_id              = var.vpc_id
  environment         = var.environment
  serviceName         = "go-docker-demo"
  app_port            = 8000
  app_temp_port       = 8080
  subnet_ids          = var.public_subnet_ids
  vpc_cidr            = data.aws_vpc.vpc.cidr_block
}

module "ecsService" {
  source                        = "./modules/ecsService"
  assign_public_ip              = true ###should be set to true for on public subnets.
  vpc_id                        = var.vpc_id
  environment                   = var.environment
  rBlueTargetGroupArn           = module.albUIService.rBlueTargetGroupArn
  alb_sg                        = module.albUIService.alb_sg
  serviceName                   = "go-docker-demo"
  app_port                      = 8000
  cpu                           = 256
  memory                        = 512
  task_name                     = "go-docker-demo"
  task_family                   = "go-docker-demo"
  task_network_mode             = "awsvpc"
  task_requires_compatibilities = "FARGATE"
  cluster_name                  = module.ecsCluster.oEcsClusterName
  cluster_id                    = module.ecsCluster.oEcsClusterId
  desired_tasks                 = 1
  max_capacity                  = 2
  ecs_service_ram_target_value  = 80
  ecs_service_cpu_target_value  = 80
  service_launch_type           = "FARGATE"
  enable_ecs_managed_tags       = "true"
  public_subnet_ids             = var.public_subnet_ids
  vpc_cidr                      = data.aws_vpc.vpc.cidr_block
  repo_url                      = module.ecrRepUIService.repoURL
}

module "go-app-codedeploy" {
  source                           = "./modules/codedeploy"
  resourceName                     = "go-docker-demo"
  ecs_service_name                 = module.ecsService.oEcsServiceName
  ecs_cluster_name                 = module.ecsCluster.oEcsClusterName
  rBlueTargetGroupName             = module.albUIService.rBlueTargetGroupName
  rGreenTargetGroupName            = module.albUIService.rGreenTargetGroupName
  rBluenListenerArn                = module.albUIService.rBluenListenerArn
  rGreenListenerArn                = module.albUIService.rGreenListenerArn
  environment                      = var.environment
  termination_wait_time_in_minutes  = "0"
  time_interval_in_minutes          = "1"
  percentage_canary_deployment      = "10"
  deployment_config_option         = "canary"
  #deployment_config_option          = "AllAtOnce"
}

module "codepipeline" {
  environment                      = var.environment
  source                             = "./modules/pipeline-deploy-module"
  serviceName                        = "go-docker-demo"
  codebuild_compute_type             = "BUILD_GENERAL1_SMALL"
  coudebuild_image                   = "aws/codebuild/standard:4.0"
  codebuid_env_type                  = "LINUX_CONTAINER"
  buildspec_lint_dir                 = "./pipeLineScripts/buildspec-lint.yml"
  repository_name                    = "sample-go-ecs-tf-codePipeline"
  repository_branch                  = "main"
  repository_owner                   = var.repository_owner
  GitHubToken                        = data.aws_ssm_parameter.GitHubToken.value
  codedeploy_role_arn                = module.go-app-codedeploy.codedeploy_role_arn
  codedeploy_applicationname         = module.go-app-codedeploy.codedeploy_applicationname
  codedeploy_groupname               = module.go-app-codedeploy.codedeploy_groupname

}
