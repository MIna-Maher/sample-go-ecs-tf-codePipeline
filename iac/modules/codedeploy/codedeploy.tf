### Add condition to choose which deployment you want to have if its canary or AllAtOnce
locals {
  deployment_config = var.deployment_config_option == "AllAtOnce" ? "CodeDeployDefault.ECSAllAtOnce" : aws_codedeploy_deployment_config.deployment_config[0].id
  isAllAtOnceApplid = var.deployment_config_option == "AllAtOnce" ? true : false
}
####Create codedeploy for deploying app on ecs cluster#####
data "aws_caller_identity" "current" {}

# create a service role for codedeploy
resource "aws_iam_role" "codedeploy_service_role" {
  name = format("%s-%s-codedeploy-service-role", var.environment, var.resourceName)

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# attach AWS managed policy called AWSCodeDeployRole
resource "aws_iam_role_policy_attachment" "codedeploy_service" {
  role       = aws_iam_role.codedeploy_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}
data "aws_iam_policy_document" "codedeploy_policy_doc" {
  statement {
    sid = "codedeploy"

    actions = [
      "s3:*",
      "ecr:*",
      "logs:*",
      "ecs:*",
      "elasticloadbalancing:*"

    ]

    resources = ["*"]
  }
  statement {
    sid = "codepipelineiamPassRole"

    actions = [

      "iam:PassRole"
    ]

    resources = [var.taskIamExecutionRoleArn, var.taskIamRoleArn]
  }
}

resource "aws_iam_policy" "codedeploypolicy" {
  name   = format("%s-task-policy", var.environment)
  policy = data.aws_iam_policy_document.codedeploy_policy_doc.json
  path   = "/"
}
resource "aws_iam_policy_attachment" "attachment" {
  name       = "taskroleattach"
  roles      = [aws_iam_role.codedeploy_service_role.name]
  policy_arn = aws_iam_policy.codedeploypolicy.arn
}

##############################################################
# CODE DEPLOY App.
resource "aws_codedeploy_app" "codeDeployApplication" {
  compute_platform = "ECS"
  name             = format("%s-%s-codedeploy-app", var.environment, var.resourceName)
  tags             = merge({ Name = format("%s-%s-codedeploy-app", var.environment, var.resourceName) })
}

#########################################
# CodeDeploy dg
resource "aws_codedeploy_deployment_group" "deploymentGroup" {
  app_name = aws_codedeploy_app.codeDeployApplication.name
  #deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_config_name = local.deployment_config
  #deployment_config_name = aws_codedeploy_deployment_config.deployment_config.id
  deployment_group_name = format("%s-%s-codedeploy-dg", var.environment, var.resourceName)
  service_role_arn      = aws_iam_role.codedeploy_service_role.arn
  tags                  = merge({ Name = format("%s-%s-codedeploy-dg", var.environment, var.resourceName) })

  auto_rollback_configuration {
    enabled = "true"
    events  = ["DEPLOYMENT_FAILURE"]
  }
  ##https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_deployment_group#deployment_style
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"

    }
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.termination_wait_time_in_minutes
    }
  }
  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }
  load_balancer_info {
    #elb_info {
    #  name = "${var.alb_name}"
    #}
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.rBluenListenerArn]
      }

      target_group {
        name = var.rBlueTargetGroupName
      }

      target_group {
        name = var.rGreenTargetGroupName
      }
      test_traffic_route {
        listener_arns = [var.rGreenListenerArn]
      }
    }
  }
}
###### Create custom canary deployment config ########
resource "aws_codedeploy_deployment_config" "deployment_config" {
  count                  = local.isAllAtOnceApplid ? 0 : 1
  deployment_config_name = format("%s-%s-codedeploy-deployment-config", var.environment, var.resourceName)
  compute_platform       = "ECS"

  traffic_routing_config {
    ###  Type of traffic routing config. One of TimeBasedCanary, TimeBasedLinear, AllAtOnce
    type = "TimeBasedCanary"

    time_based_canary {
      ### The number of minutes between the first and second traffic shifts of a TimeBasedCanary deployment
      interval = var.time_interval_in_minutes
      ### The percentage of traffic to shift in the first increment of a TimeBasedCanary deployment.
      percentage = var.percentage_canary_deployment
    }
  }
}
#########################################################