# Sample containrized Go App. 
## For Running the Dockerized app locally, please run these:
sh
```
docker build  -t agoapp .
docker run --name agoapp-demo -itd -p 8000:8000 agoapp
```