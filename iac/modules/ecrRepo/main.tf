locals {
  ################# Add condition for KMS Key to be null in case of SSE is AES256 encryption alogorithm############
  kms_key = var.encryption_type == "KMS" ? var.kms_key : ""
}
resource "aws_ecr_repository" "ecr_repo" {
  name = format("%s-%s-ecr-repo", var.environment, var.serviceName)
  #https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-tag-mutability.html
  image_tag_mutability = var.image_tag_mutability
  ##https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning.html
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
  tags = merge({ Name = format("%s_%s-ecr-repo", var.environment, var.serviceName) })
  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = local.kms_key
  }
}
####### Add ecr lifecycle policy to delete images after x days ###############
###### for more info about all available rules ::: https://docs.aws.amazon.com/AmazonECR/latest/userguide/lifecycle_policy_examples.html

resource "aws_ecr_lifecycle_policy" "repo_lifecycle_policy" {
  repository = aws_ecr_repository.ecr_repo.name
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Rule 1",
            "selection": {
                "tagStatus": "${var.image_tag_status}",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": ${var.image_expiration_in_days}
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
####### Adding Repo permission to allow other services to push/pull docker images######