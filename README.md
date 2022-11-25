# Containrized go-docker-demo app.
## About

- This doc is to guide how to implement sample containrized go-docker-demo app locally and on AWS ECS service and also how to deploy new version using DevOps CICD automated pipeline.

## Table of Contents

1. [Intro](#Intro)
2. [Testing Locally](#Testing Locally)

### Intro

- This sample app is built using go language and is deployed on AWS ECS fargate service.
- AWS resources are created with IAC using terraform.
- Automated pipeline through AWS CodePipeline, CodeBuild and CodeDeploy.

### Testing Locally

- For testing app locally on machines with Docker, please run the below <ins>commands</ins>: 
sh ```
docker build  -t goapp .
docker run --name goapp-demo -itd -p 8000:8000 goapp
```