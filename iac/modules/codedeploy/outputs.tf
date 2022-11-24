output "codedeploy_role_arn" {
  value = aws_iam_role.codedeploy_service_role.arn
}
output "codedeploy_applicationname" {
  value = aws_codedeploy_app.codeDeployApplication.id
}
output "codedeploy_groupname" {
  value = aws_codedeploy_deployment_group.deploymentGroup.id
}