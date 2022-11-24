resource "aws_ecs_cluster" "ecsCluster" {
  name = format("%s_%s-ecs-cluster", var.environment, var.clusterName)
  tags = merge({ Name = format("%s_%s-ecs-cluster", var.environment, var.clusterName) })

  setting {
    name  = "containerInsights"
    value = var.container_insights
  }
  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }
}
