# Containrized go-docker-demo app.
## About

- This doc is to guide how to implement sample containrized go-docker-demo app locally and on AWS ECS service and also how to deploy new version using DevOps CICD automated pipeline.

## Table of Contents

1. [Intro](#Intro)
2. [Testing Locally](#Testing-Locally)
3. [Design Architecture](#Design-Architecture)
4. [Design Aspects](#Design-Aspects)

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

### Design Aspects

- Application is deployed on public subnets with internet-facing scheme to allow the customers to access our application externally.

- Incase of the business need to allow the access of our app internally throught VPC, The IAC Code handles this throgh configuring this [attribute](https://github.com/MIna-Maher/sample-go-ecs-tf-codePipeline/blob/b595c97dea2ce4cfb4b6697026a022f8c97d0a29/iac/go-docker-demo.tf#L50) to **true** and configure **private_subnets** instead of [public_subnets](https://github.com/MIna-Maher/sample-go-ecs-tf-codePipeline/blob/b595c97dea2ce4cfb4b6697026a022f8c97d0a29/iac/go-docker-demo.tf#L91)

- <ins>**Note**</ins>: For more dtails about the traffic flow from internet-facing ALB and how it routes the traffic to the private intances, please refer to [AWS Official Doc](https://docs.aws.amazon.com/prescriptive-guidance/latest/load-balancer-stickiness/subnets-routing.html).

- The IAC code handles configuring the ALB listernes with SSL for securing the connection the communication by configuring this [attribute](https://github.com/MIna-Maher/sample-go-ecs-tf-codePipeline/blob/0e04eab3d080c6e0259fea5cb868cdd8fefc7336/iac/go-docker-demo.tf#L49) to **true** and also configuring the [domain](https://github.com/MIna-Maher/sample-go-ecs-tf-codePipeline/blob/0e04eab3d080c6e0259fea5cb868cdd8fefc7336/iac/go-docker-demo.tf#L53) name of choosen ACM certificate.

- Go App is deployed using AWS ECS Fargate, Fargate is a serverless compute engine for containers that abstracts the underlying infrastructure and can be used to launch and run containers without having to provision or manage EC2 instances. Users don’t need to worry about instances or servers, they need to define resource requirements.

- App tasks are deployed on private subnets "App Private Tier" and accept connection only from ALB SG for securing our app.

- ECS Service is created with desired **1** task with cpu: 256 && RAM: 512 , and enable service autoscaling for autoscaling the number of tasks incase of increasing the load.
- Service AutoScaling: ![Service Autoscaling](./images/scale.jpeg)

- For configring scaling average tracking metrics for cpu/ram, number of desired/max tasks, please configure these params according to your need, this configs can be found on [go-docker-demo.tf](./iac/go-docker-demo.tf) and also for the pipeline [task def](./pipeLineScripts/postBuild.sh):

 <ins>**go-docker-demo.tf**</ins>:

```
  cpu                           = 256
  memory                        = 512
  task_name                     = "go-docker-demo"
  task_family                   = "go-docker-demo"
  task_network_mode             = "awsvpc"
  task_requires_compatibilities = "FARGATE"
  cluster_name                  = module.ecsCluster.oEcsClusterName
  cluster_id                    = module.ecsCluster.oEcsClusterId
  desired_tasks                 = 1
  max_capacity                  = 2
  ecs_service_ram_target_value  = 80
  ecs_service_cpu_target_value  = 80
```
 <ins>**taskdef**</ins>:
```sh
  export taskCPU=256
  export taskRAM=512
  export aws_logs_group=${env}-go-docker-demo-log-group
```

- <ins>**Note**</ins>: For configuring fargate cpu/ram for your task, please refer to [AWS Doc](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html).

