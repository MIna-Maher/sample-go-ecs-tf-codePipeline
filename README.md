# Containrized go-docker-demo app.
## About

- This doc is to guide how to implement sample containrized go-docker-demo app locally and on AWS ECS service and also how to deploy new version using DevOps CICD automated pipeline.

## Table of Contents

1. [Intro](#Intro)
2. [Testing Locally](#Testing-Locally)
3. [Design Architecture](#Design-Architecture)

### Intro

- This sample app is built on go language and deployed on AWS ECS fargate service.
- AWS resources are created with IAC using terraform.
- Automated pipeline through AWS CodePipeline, CodeBuild and CodeDeploy.

### Testing Locally

- For testing app locally on machines with Docker, please run the below <ins>commands</ins>: 
```
docker build  -t goapp .
docker run --name goapp-demo -itd -p 8000:8000 goapp
```
- <ins>**Note**</ins>: Docker needs to e installed on machine locally, for installation tips according to your OS platform, please check this [Docker official docs](https://docs.docker.com/engine/install/).
- For hitting your go app locally, please run this on your broswer:
```
http://127.0.0.1:8000
```
### Design Architecture

![Design Architecture:](./images/design.jpg)
- 