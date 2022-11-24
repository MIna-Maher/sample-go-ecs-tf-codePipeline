#!/bin/bash -e
env=$(printenv DEPLOY_ENVIRONMENT)
accountId=$(printenv ACCOUNT_ID)
#ASSUME ROLE Using Account ID and Env
export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
$(aws sts assume-role \
--role-arn arn:aws:iam::${accountId}:role/${env}_crossaccount-pipeline-role \
--role-session-name AWSCLI-Session \
--query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
--output text))
#######################
# Get Needed SSM Parameters(Looking on target account like lab, dev, prod,.....)
versionParamName="/appserver-fe/version"
packageParam=$(cat package.json | jq -c .version)
versionParam=$(aws ssm describe-parameters --parameter-filters "Key=Name,Values=$versionParamName" | jq -c .Parameters)

size=$(echo $versionParam | jq length)

## Check if its the first time if so then it will continue the pipeline 
## If there is a version param in ssm it will check if its different than the one in package.json
##  if so it will continue the pipeline , otherwise it will stop the pipeline as there are no difference in versions
if [ $size -eq 0 ]
then 
    echo "No Parameter With This Name"
    echo "Create SSM Parameter with the app version: ${packageParam}"
    ssmOutput=$(aws ssm put-parameter --name "$versionParamName" --type "String" --value "$packageParam" --overwrite)
    echo "SSM Parameter created successfully, (SSM Param: ${ssmOutput})"
else   
    echo "Parameter Found"
    ssmParam=$(aws ssm get-parameter --name "$versionParamName"  --query Parameter.Value --output text)
    #echo $ssmParam
    if [ "$ssmParam" = "$packageParam" ]
    then 
        echo "SSM Param: $ssmParam Equal Package Param: $packageParam"
        unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
        pl_execution_id=$(aws codepipeline get-pipeline-state --region ${AWS_REGION} --name ${CODEBUILD_INITIATOR#codepipeline/} --query 'stageStates[?actionStates[?latestExecution.externalExecutionId==`'${CODEBUILD_BUILD_ID}'`]].latestExecution.pipelineExecutionId' --output text)
        pl_stop_execution_reason="version_is_same"
        aws codepipeline stop-pipeline-execution --region ${AWS_REGION} --pipeline-name ${CODEBUILD_INITIATOR#codepipeline/} --pipeline-execution-id ${pl_execution_id} --abandon --reason ${pl_stop_execution_reason} --output text
        echo ""
        if [ $? -eq 0 ]
        then
            echo "Pipeline execution (ID: ${pl_execution_id}) is stopped"
            exit 2
        else
            echo "Failed to stop pipeline execution (ID: ${pl_execution_id})"
            exit 1
        fi
    else
        echo "SSM Param: $ssmParam Not Equal Package Param: $packageParam"
    fi
    
fi
###########################