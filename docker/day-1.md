# Day-1
- deployment in pyhiscal,vm and containers
- docker
- docker architecture
- containers
- contaienr life cycle
- namespaces & cgroups
- basic commands[logs,inspect,stats,run,rmi,rm,stop,pause,unpause,prune,system]

**InterviewQuestions**
- What are the challenges that are there applications are deployed in Physical Machines
- How VM  addressses the challenges in Physical Machines
- Why VM are not suitable for micro services deployments and what are the challenges in VM deployment
- What is virtulization 
- What is containerization
- What is docker
- Can you please explain docker architecture
- What is Container and it's benefits
- What is namepsaces and cGroups and role in containers
- What are the Dangling images
- How can you inspect the container|network|volumes|image|containers
- How to check the logs of container
- Can you Please Explain Container lifeCycle
 




















 1. dangling images are untagged images that are usually intermediate layers of old or failed builds

```bash
docker images -f "dangling=true"
```

```bash
docker rmi $(docker images -f "dangling=true" -q)
```

```bash
docker image prune -a
```