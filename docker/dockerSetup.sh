#!/bin/bash
#This script is used to setup Docker Registry and Deploy Viz Service
#This must be run one time when Docker Swarm is Created
#This must be executed only on Docker Swarm master
#Administrator must manually connect to Worker Node and Add them to Swarm
#Email  : Senthil Nathan Manoharan
#Contact: senthil.nathanm@yahoo.com


#Running Checks before Initializing Docker Swarm
#(1) Check if Docker Is Installed
if (( $(rpm -qa | grep -i docker-ce | wc -l) == 0 ));
then
  echo "Docker Packages Are not Installed Correctly"
  echo "Install it first"
  echo "Terminating Execution"
  exit 1
fi
#(2) Check User privelege to execute docker commands
if (( $(id | grep docker | wc -l) != 1));
then
  echo "Current User must be added to docker group"
  echo "Terminating Execution"
  exit 1
fi
#Preliminary checks completed
#Instantiating Docker Swarm
docker swarm init
if [[ $? -ne 0 ]]
then
  echo "Docker Swarm Instantiation Failed"
  echo "Terminating Execution"
  exit 1
fi
#Deploying Visualization Service on Master Node
docker service create \
		--name=viz \
		--publish=8181:8181 \
		--constraint=node.role==manager \
		--mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
		dockersamples/visualizer
if [[ $? -ne 0 ]]
then
  echo "Docker Visualization Service Instantiation Failed"
  echo "Terminating Execution"
  exit 1
fi
exit 0
