#### Create log group to be used by awslogs log driver by task.
resource "aws_cloudwatch_log_group" "log_group" {
  name              = format("%s-%s-log-group", var.environment, var.clusterName)
  tags              = merge({ Name = format("%s-%s-log-group", var.environment, var.clusterName) })
  retention_in_days = var.log_group_retention_in_days
}