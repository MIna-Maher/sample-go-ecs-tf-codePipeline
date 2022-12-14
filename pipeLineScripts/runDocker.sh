#!/bin/bash -e
env=$(printenv DEPLOY_ENVIRONMENT)
accountId=$(printenv ACCOUNT_ID)
AWS_DEFAULT_REGION=$(printenv REGION_NAME)
ecr_docker_repo=${env}-go-docker-demo-ecr-repo

docker --version

#########################

###########################################################################################
echo "Building New  Docker iamge..."
#temp solution
docker login --username=minamahertest --password=123456789
export DOCKER_BUILDKIT=1
docker build  -t ${ecr_docker_repo}:latest ./
#docker tag ${ecr_docker_repo}:latest ${accountId}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ecr_docker_repo}:latest
##
echo "Logging in to Amazon ECR Repo:... "
aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${accountId}.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
echo "Publish the image to ecr repo:...."
docker tag ${ecr_docker_repo}:latest ${accountId}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ecr_docker_repo}:latest
docker push ${accountId}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ecr_docker_repo}:latest
docker logout
###########################
