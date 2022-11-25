################# Create CodeBuild Role################
##############Customized Role and policy according to the resources#####################
data "aws_iam_policy_document" "codedeploypolicy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "codebuildRole" {
  name = "${var.environment}_${var.serviceName}_codebuild"
  ####name will be according to the target env will use this codebuild project to deploy to
  assume_role_policy = data.aws_iam_policy_document.codedeploypolicy.json
}
data "aws_iam_policy_document" "codebuildPolicydocument" {
  statement {
    sid = "codepipelineaccess"

    actions = [
      "codepipeline:AcknowledgeJob",
      "codepipeline:DisableStageTransition",
      "codepipeline:EnableStageTransition",
      "codepipeline:GetJobDetails",
      "codepipeline:GetPipelineExecution",
      "codepipeline:GetPipelineState",
      "codepipeline:GetPipeline",
      "codepipeline:ListPipelineExecutions",
      "codepipeline:PollForJobs",
      "codepipeline:PutActionRevision",
      "codepipeline:PutApprovalResult",
      "codepipeline:PutJobFailureResult",
      "codepipeline:PutJobSuccessResult",
      "codepipeline:RetryStageExecution",
      "codepipeline:StartPipelineExecution",
      "codepipeline:StopPipelineExecution",
      "logs:GetLogEvents",
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutRetentionPolicy",
      "logs:CreateLogGroup",
      "logs:FilterLogEvents",
      "s3:GetObject",
      "s3:List*",
      "s3:PutObject",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:GetObjectVersion",
      "sts:AssumeRole",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "ecr:*"
    ]

    resources = ["*"]
  }
}

###############################Create Codebuild policy #############################
resource "aws_iam_policy" "codebuildRolePolicy" {
  name = "${var.environment}_${var.serviceName}_codebuildrolepolicy"
  #role = aws_iam_role.codebuildRole.name
  policy = data.aws_iam_policy_document.codebuildPolicydocument.json
  path   = "/"
}
resource "aws_iam_policy_attachment" "attachment" {
  name       = "codedeployattach"
  roles      = [aws_iam_role.codebuildRole.name]
  policy_arn = aws_iam_policy.codebuildRolePolicy.arn
}
####
data "aws_caller_identity" "current" {}

################ Create code pipeline Role################
##############Customized Role and policy according to the resources#####################
data "aws_iam_policy_document" "codepipelinepolicy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "codepipelineRole" {
  name = "${var.environment}_${var.serviceName}_codepipelinerole"
  ####name will be according to the target env will use this codebuild project to deploy to
  assume_role_policy = data.aws_iam_policy_document.codepipelinepolicy.json
}
data "aws_iam_policy_document" "codepipelinePolicydocument" {
  statement {
    sid = "codepipelineaccess"

    actions = [
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:UploadArchive",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:CancelUploadArchive",
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codepipeline:AcknowledgeJob",
      "codepipeline:DisableStageTransition",
      "codepipeline:EnableStageTransition",
      "codepipeline:GetJobDetails",
      "codepipeline:GetPipelineExecution",
      "codepipeline:GetPipelineState",
      "codepipeline:GetPipeline",
      "codepipeline:ListPipelineExecutions",
      "codepipeline:PollForJobs",
      "codepipeline:PutActionRevision",
      "codepipeline:PutApprovalResult",
      "codepipeline:PutJobFailureResult",
      "codepipeline:PutJobSuccessResult",
      "codepipeline:RetryStageExecution",
      "codepipeline:StartPipelineExecution",
      "codepipeline:StopPipelineExecution",
      "s3:GetObject",
      "s3:List*",
      "s3:PutObject",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:GetObjectVersion",
      "sts:AssumeRole",
      "codedeploy:*",
      "iam:PassRole",
      "ecs:RegisterTaskDefinition"
    ]

    resources = ["*"]
  }
  statement {
    sid = "codepipelineiamPassRole"

    actions = [
      
      "iam:PassRole"
    ]

    resources = ["arn:aws:iam::452750642022:role/prd-go-docker-demo-task-role","arn:aws:iam::452750642022:role/prd-go-docker-demo-task-execution-role"]
  }

}

###############################Create Codebuild policy #############################
resource "aws_iam_policy" "codepipelineRolePolicy" {
  name = "${var.environment}_${var.serviceName}_codepipelinerolepolicy"
  #role = aws_iam_role.codebuildRole.name
  policy = data.aws_iam_policy_document.codepipelinePolicydocument.json
  path   = "/"
}
resource "aws_iam_policy_attachment" "attachment_pipeline" {
  name       = "codepipelineattach"
  roles      = [aws_iam_role.codepipelineRole.name]
  policy_arn = aws_iam_policy.codepipelineRolePolicy.arn
}
####