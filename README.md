# Jenkins as Docker Containers

# Introduction

Jenkins has become the go-to tool for any development team and organizations end up managing several jenkins instances in various state of decay. A centrally hosted jenkins infrastructure with a much simpler but tightly controlled configuration will help address some of the shortcomings of desparate jenkins environments. This page explains in detail, a new dockers based Jenkins infrastructure. The setup comprise of Docker Swarm which manage multiple Jenkins instances as docker services. The docker service themselves are managed programmatically using terraform. The interaction between the IT administrator and the underlying Jenkins containers are only through terraform code which makes API calls to the docker services to manage both the container's state as well as configuration.

# Deployment Architecture

The overall architecture of the Jenkins environment is show below. The setup consists of

- Three VM Guest nodes which run the containers
- Docker Swarm, comprising of a single master node and two worker nodes
- Terraform installed on the master node to manage the docker swarm 
- A series of Bash scripts which acts as interface between the required Jenkins configurations defined for the project and the terraform modules
- A single property file which is the only place all Jenkins configurations are maintained (including plugin updates)

![Deployment Architecture](https://github.com/senthilmnathan/jenkins-in-docker_swarm/blob/master/deployment_architecture.png)

The entire cycle from configuration definition to spawning of container is given here. Except for creating the project specific property file and executing the bash script, all these steps are performed automatically.

![Flow Diagram](https://github.com/senthilmnathan/jenkins-in-docker_swarm/blob/master/flowchart.png)

# Docker Swarm
The docker swrm in this case is setup across three nodes with a single master node

# Property file
This is the first step in creating the Jenkins container. The property file is prepared by the middleware administrator based on requirements from project team which requested the environment. This file contains rudimentary information like
- List of packages to be installed
- List of plugins to be installed
- Admin user password
- Contact Email ID



# Custom Docker Image
For each Jenkins instance, a custom docker image is created in order to better manage the configurations pertaining to it. The docker image is created by a shell script which reads the property file as input. Using the information from the file, a custom image is created.

![Docker Images](https://github.com/senthilmnathan/jenkins-in-docker_swarm/blob/master/docker_image.png)

# Local Docker Registry
This is a lightweight docker container which only runs on the Swarm master node. The custom image created in the previous stage is pushed to this registry in order to make it available to all nodes in the docker swarm. The image is automatically published in the registry without any user intervention

# Terraform
The terraform module is the key component that ties everything together. Each Jenkins container is instantiated as a docker service through the terraform module. It consists of two parts.

## Terraform Module
The definition of docker service is coded in the terraform module. The module defines the following resources used by the docker service.

- Network
- Image
- Volume

The build process automatically creates a directory for each Jenkins instance with the terraform code automatically populated. The state for each environment is maintained within these directory and it is imperative that it is not tampered with in any form.

## Terraform variable File
A terraform.tfvars file is created for each Jenkins instance which consists of values for the following variables defined within the terraform module.

- Project Name
- Docker Image Name
- Web Interface Port
- API Interface Port

This file typically looks like this

![terraform.tfvars](https://github.com/senthilmnathan/jenkins-in-docker_swarm/blob/master/tfvars_file.png)

# Docker Service
The entire process works towards creating the docker service which in turn spawns the docker container on a free host. The docker service is just a container with definition that govern the container's behaviour. In this case, the docker service for a Jenkins instance define the image, ports etc to be used.

![Docker Service](https://github.com/senthilmnathan/jenkins-in-docker_swarm/blob/master/docker_service.png)

# Docker Container
The docker container, with all the values provided in earlier steps, is spawned and the Jenkins instance is made available to the users. 

![Docker Container](https://github.com/senthilmnathan/jenkins-in-docker_swarm/blob/master/docker_container.png)

# Docker Volume
Once the users start creating build jobs, it is important for the data to persist. Default behaviour for docker containers is that the entire container file system is deleted when the container is stopped or restarted. To mitigate this problem, the Jenkins data is stored on a local file system. Specifically, the container's "/var/jenkins_home" directory and all its contents are stored on an NFS volume.

# Data persistence across Swarm
Since the container is managed by docker swarm, it is possible that a given Jenkins instance can be created on one node and moved to a different node for various reasons. When this happens, the data created on the previous node will not be available pushing the instance to an inconsistent state. To overcome this, a shared NFS volume is setup which will be available across all the VM guests which also makes the data available across all swarm nodes.

# Visualization Container
The Visualization container is just a helper container which displays a visual of various containers and nodes that are in the Swarm. This can used used to monitor state of various containers within the swarm at real time.

![Viz Container](https://github.com/senthilmnathan/jenkins-in-docker_swarm/blob/master/docker_viz.png)

# Building An Instance
This section gives a blow by blow of the steps involved in building a new environment. All the steps given here are performed only on master node
- Navigate to /app/jenkins/properties
- Create a new file with the name, <project_name>.properties and populate it with relevant details
- Navigate to /app/jenkins/builder
- Execute master.sh and pass the property file with absolute part as run time parameter
- master.sh /app/jenkins/properties/sample.properties
- When the scripts prompts for Yes or No, select Yes to go ahead and deploy the instance

## deployer.sh
The deployer.sh file internally calls three other bash scripts all of which are in /app/jenkins/builder/.
- image_builder.sh: This creates the custom image for the instance
- terraform_builder.sh: This creates the terraform module for the instance and populates terraform.tfvars with relevant details
- deployer.sh: Deploys the terraform code and creates the docker service

# Enhancements
Developers proficient in Java programming can create a JSP based interface which can encapsulate the entire complexity of tool interation
This can also be integrated with ticket based systems like ServiceNow using API calls which can fully automate instance requests


