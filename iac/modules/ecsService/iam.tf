######## Create ecs task role and policy#######
data "aws_iam_policy_document" "task_role_service" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "ecs_task_role" {
  name               = format("%s-%s-task-role", var.environment, var.serviceName)
  assume_role_policy = data.aws_iam_policy_document.task_role_service.json
}
data "aws_iam_policy_document" "taskrole_policy_doc" {
  statement {
    sid = "taskRolePolicy"

    actions = [
      "s3:*",
      "ecr:*",
      "logs:*",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "taskpolicy" {
  name   = format("%s-%s-task-policy", var.environment, var.serviceName)
  policy = data.aws_iam_policy_document.taskrole_policy_doc.json
  path   = "/"
}
resource "aws_iam_policy_attachment" "attachment" {
  name       = "taskroleattach"
  roles      = [aws_iam_role.ecs_task_role.name]
  policy_arn = aws_iam_policy.taskpolicy.arn
}
###############################
## Create ecs task exec role
#### Attach AmazonECSTaskExecutionRolePolicy to the task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = format("%s-%s-task-execution-role", var.environment, var.serviceName)
  assume_role_policy = data.aws_iam_policy_document.task_role_service.json
}

resource "aws_iam_role_policy_attachment" "task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "task_execution_policy_CloudWatchAgentServerPolicy" {
  role       = aws_iam_role.ecs_task_execution_role.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

