#output "rTargetGroupArn" {
#  value = aws_alb_target_group.awsTargetGroup.arn
#}

output "alb_sg" {
  value = aws_security_group.lb.id
}
output "rBlueTargetGroupArn" {
  value = aws_alb_target_group.awsBlueTargetGroup.arn
}
## 
output "rBlueTargetGroupName" {
  value = aws_alb_target_group.awsBlueTargetGroup.name

}
output "rGreenTargetGroupName" {
  value = aws_alb_target_group.awsGreenTargetGroup.name

}
output "rBluenListenerArn" {
  value = aws_alb_listener.awsBlueTargetGroupListener.arn

}

output "rGreenListenerArn" {
  value = aws_alb_listener.awsGreenTargetGroupListener.arn

}