#!/bin/bash -e
echo "Starting Post Build Stage....."
env=$(printenv DEPLOY_ENVIRONMENT)
ecr_docker_repo=${env}-go-docker-demo-ecr-repo
AWS_DEFAULT_REGION=$(printenv REGION_NAME)
echo "Preparing taskdef file...."
export ecs_task_execution_role="$env-go-docker-demo-task-execution-role"
export ecs_task_role="$env-go-docker-demo-task-role"
export taskCPU=256
export taskRAM=512
export aws_logs_group=${env}-go-docker-demo-log-group

cat ./pipelineScripts/taskdef.json.template | envsubst > taskdef.json
cat taskdef.json
echo "Creating imageDetail.json"
printf '{"ImageURI":"%s"}' ${accountId}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ecr_docker_repo}:v${dockerPackageVersion} > imageDetail.json
ls
cat imageDetail.json
cat ./pipelineScripts/appspec.yml | envsubst > appspec.yml
cat appspec.yml
######################################
