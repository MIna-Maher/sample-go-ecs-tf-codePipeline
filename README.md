# Sample containrized go-docker-demo app.
## About

- This doc is to guide how to implement sample containrized go-docker-demo app locally and on AWS ECS service and also how to deploy new version using DevOps CICD pipeline.

## Table of Contents
1. [My first title](#my-first-title)

## My first title
Some text.


## For Running the Dockerized app locally, please run these:

```
docker build  -t agoapp .
docker run --name agoapp-demo -itd -p 8000:8000 agoapp
```