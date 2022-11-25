output "oEcsServiceName" {
  value = aws_ecs_service.svc_LB.name
}
output "taskIamRoleArn" {
  value = aws_iam_role.ecs_task_role.arn
}

output "taskIamExecutionRoleArn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}