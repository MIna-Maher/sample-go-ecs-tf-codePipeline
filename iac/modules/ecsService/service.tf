
resource "aws_ecs_service" "svc_LB" {
  name                    = format("%s-%s-ecs-service", var.environment, var.serviceName)
  tags                    = merge({ Name = format("%s_%s-ecs-service", var.environment, var.serviceName) })
  cluster                 = var.cluster_id
  task_definition         = aws_ecs_task_definition.TaskDefinition.arn
  desired_count           = var.desired_tasks
  launch_type             = var.service_launch_type
  enable_ecs_managed_tags = var.enable_ecs_managed_tags
  enable_execute_command  = true
  force_new_deployment    = true
  network_configuration {
    security_groups  = [aws_security_group.service_sg_alb.id]
    subnets          = var.public_subnet_ids
    assign_public_ip = var.assign_public_ip
  }
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  load_balancer {
    target_group_arn = var.rBlueTargetGroupArn
    container_name   = var.task_name
    container_port   = var.app_port
  }
  lifecycle {
    ignore_changes = [
      desired_count,
      load_balancer,
      task_definition,
      launch_type,
    ]
  }
}

###### Add ecs service autoscaling #######
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity = var.max_capacity
  min_capacity = var.desired_tasks
  resource_id  = "service/${var.cluster_name}/${aws_ecs_service.svc_LB.name}"
  #resource_id        = "service/${var.cluster_name}/${aws_ecs_service.svc.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_ram" {
  name               = "${var.cluster_name}-${var.serviceName}-targetScaleRam"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      ### Please check all available predefined metrics for services https://docs.aws.amazon.com/autoscaling/application/userguide/application-auto-scaling-target-tracking.html
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = var.ecs_service_ram_target_value

  }
}
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "${var.cluster_name}-${var.serviceName}-targetScaleCPU"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      ### Please check all available predefined metrics for services https://docs.aws.amazon.com/autoscaling/application/userguide/application-auto-scaling-target-tracking.html
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.ecs_service_cpu_target_value

  }
}
