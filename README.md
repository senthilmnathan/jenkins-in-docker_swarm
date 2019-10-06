**Jenkins as Docker Containers**

**Introduction**

This page explains in detail, the new dockers based Jenkins instances. The setup comprise of Docker Swarm which manage multiple Jenkins instances as docker services. The docker service themselves are managed programmatically using terraform. The interaction between the IT administrator and the underlying Jenkins containers are only through terraform code which makes API calls to the docker services to manage both the container's state as well as configuration.

**Deployment Architecture**

The overall architecture of the Jenkins environment is show below. The setup consists of

- Three VM Guest nodes which run the containers
- Docker Swarm, comprising of a single master node and two worker nodes
- Terraform installed on the master node to manage the docker swarm 
- A series of Bash scripts which acts as interface between the required Jenkins configurations defined for the project and the terraform modules
- A single property file which is the only place all Jenkins configurations are maintained (including plugin updates)

