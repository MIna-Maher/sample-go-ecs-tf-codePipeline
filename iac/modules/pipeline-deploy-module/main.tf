
################Create s3 bucket for storing codepipeline outputs artifacts##########
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.environment}-${var.serviceName}-artifacts"
  force_destroy = "true"
}
##### According to the latest change in AWS terraform module############
resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}
############# Blcok Public access for codepipeline_bucket for securely store artifacts#############
resource "aws_s3_bucket_public_access_block" "codePipelineS3PublicAccess" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

####################Create CodeBuild project for lint and build ########################
resource "aws_codebuild_project" "codeBuildProjectlint" {
  name         = "${var.environment}_${var.serviceName}_codebuildlint"
  tags         = merge({ TargetEnv = var.environment }, { ResourceGroup = var.serviceName } )
  description  = "terraform_codebuild_project_for_lint"
  service_role = aws_iam_role.codebuildRole.arn

  artifacts {
    type = "CODEPIPELINE"
  }
  #############https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project#environment
  environment {
    compute_type                = var.codebuild_compute_type
    image                       = var.coudebuild_image
    type                        = var.codebuid_env_type
    image_pull_credentials_type = "CODEBUILD"
    ##https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities
    privileged_mode = true

    environment_variable {
      name  = "CI"
      type  = "PLAINTEXT"
      value = "1"
    }
    environment_variable {
      name  = "CODEPIPELINE_STAGE"
      type  = "PLAINTEXT"
      value = "lint"
    }
    ######## Passing the DEPLOY_ENVIRONMENT to the codebuild container while running to define the target account we want to deploy to,
    ########-e, --deploy-environment" option,- "DEPLOY_ENVIRONMENT" environment variable
    environment_variable {
      name  = "DEPLOY_ENVIRONMENT"
      type  = "PLAINTEXT"
      value = var.environment
    }

    #environment_variable {
    #  name  = "ACCOUNT_ID"
    #  type  = "PLAINTEXT"
    #  value = var.Target_Acc_Id
    #}
#
    #environment_variable {
    #  name  = "REGION_NAME"
    #  type  = "PLAINTEXT"
    #  value = var.RegionName
    #}
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec_lint_dir
  }
}

##########################GitHUB Configuration and Webhook#########################

# A shared secret between GitHub and AWS that allows AWS
# CodePipeline to authenticate the request came from GitHub.
locals {
  webhook_secret = var.GitHubToken
}
##############################################################
#################Create CodePipeline webhook###################
resource "aws_codepipeline_webhook" "codepipelineWebhook" {
  tags            = merge({ TargetEnv = var.environment }, { ResourceGroup = var.serviceName } )
  name            = "${var.environment}_${var.serviceName}_codepipelineWebhook"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.static_pipeline.name

  authentication_configuration {
    secret_token = local.webhook_secret
  }

  filter {
    json_path    = var.webhook_filter_json_path
    match_equals = var.webhook_filter_match_equals
  }
}
# Wire the CodePipeline webhook into a GitHub repository.
resource "github_repository_webhook" "githubWebhook" {
  repository = var.repository_name

  configuration {
    url          = aws_codepipeline_webhook.codepipelineWebhook.url
    content_type = "json"
    insecure_ssl = false
    secret       = local.webhook_secret
  }

  events = [var.webhook_event]
}
#################Create CodePipeline #####################
###########################################################################################
resource "aws_codepipeline" "static_pipeline" {
  name     = "${var.environment}_${var.serviceName}_pipeline"
  tags     = merge({ TargetEnv = var.environment }, { ResourceGroup = var.serviceName })
  role_arn = aws_iam_role.codepipelineRole.arn
  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }
  #######################Codepipeline first stage ###################################
  stage {
    name = "Source"
    action {
      name      = "Source"
      category  = "Source"
      owner     = "ThirdParty"
      provider  = "GitHub"
      run_order = 1
      version   = "1"
      configuration = {
        "Branch"               = var.repository_branch
        "Owner"                = var.repository_owner
        "PollForSourceChanges" = "false"
        "Repo"                 = var.repository_name
        "OAuthToken"           = var.GitHubToken
      }
      input_artifacts = []

      output_artifacts = [
        "SourceArtifact",
      ]

    }
  }
  ##################################################################################
  stage {
    name = "invoke_LintCodeBuildProject"

    action {
      name = "invoke_LintCodeBuildProject"
      output_artifacts = [
        "OutputArtifact",
      ]
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["SourceArtifact"]
      version         = "1"
      run_order       = 2

      configuration = {
        ProjectName = aws_codebuild_project.codeBuildProjectlint.name
      }
    }
  }
  ############################################################################################

  stage {
    name = "Deploy"
    action {
      name            = "ExternalDeploy"
      role_arn        = var.codedeploy_role_arn
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      version         = "1"
      run_order       = 3
      input_artifacts = ["OutputArtifact"]
      configuration = {
        ApplicationName                = var.codedeploy_applicationname
        DeploymentGroupName            = var.codedeploy_groupname
        TaskDefinitionTemplateArtifact = "OutputArtifact"
        TaskDefinitionTemplatePath     = "taskdef.json"
        AppSpecTemplateArtifact        = "OutputArtifact"
        AppSpecTemplatePath            = "appspec.yml"
        Image1ArtifactName             = "OutputArtifact"
        Image1ContainerName            = "IMAGE1_NAME"
      }
    }
  }


}
##################################################################################

