## Create Task def ####

data "template_file" "TaskDefinitionTemplate" {
  template = file("${path.module}/templates/app.json")

  vars = {
    app_port   = var.app_port
    app_memory = var.memory
    app_cpu    = var.cpu
    name       = var.task_name
    repo_url   = var.repo_url
  }
}

resource "aws_ecs_task_definition" "TaskDefinition" {
  family                   = var.serviceName
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = var.task_network_mode
  requires_compatibilities = [var.task_requires_compatibilities]
  container_definitions    = data.template_file.TaskDefinitionTemplate.rendered
  tags                     = merge({ Name = format("%s-%s-ecs-task-def", var.environment, var.serviceName) })
  #lifecycle {
  #  ignore_changes = [
  #    container_definitions
  #  ]
  #}
}