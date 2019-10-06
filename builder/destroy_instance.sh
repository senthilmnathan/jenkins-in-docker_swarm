#!/bin/bash
#The script will be used to destroy an instance
#Use this only to decommission a Jenkins environment
#There will be no backup of any data. All will be lost
#Execution Syntax: ./destroy_instance.sh <absolute_path_to_valid_property_file_name>
#Execution Example: ./destroy_instance.sh /app/jenkins/properties/sample.properties
#Created By senthil Nathan Manoharan
#Contact : senthil.nathanm@yahoo.com
if [ $# -eq 0 ]; then
    echo "No arguments provided"
    echo "Example:./deployer.sh /app/jenkins/properties/sample.properties"
    exit 1
fi

#Initialize Files and Variables
PROPERTY_FILE=$1
TERRAFORM_HOME="/app/jenkins/terraform"
VOLUME_HOME="/jenkins"

#Fetch project Name
ProjectName=$(cat ${PROPERTY_FILE} | grep ProjectName | awk -F: '{print $NF}' | tr '[:upper:]' '[:lower:]')

#Destroying Terraform Instance
cd ${TERRAFORM_HOME}/${ProjectName}
terraform destroy -auto-approve
#Destroying Docker Image from Registry
docker images | grep ${ProjectName} | awk '{print $3}' | sort | uniq | xargs docker rmi --force {} 2>/dev/null
if [ $? -ne 0 ]
then
  echo "Error Occurred during Docker image deletion"
  echo "Cannot Proceed Further"
  echo "Terminating Execution"
  exit 1
fi
#Deleting the Container workspace
rm -Rf ${VOLUME_HOME}/${ProjectName}
if [ $? -ne 0 ]
then
  echo -e "Some files could not be successfully deleted"
  echo -e "Delete them as ROOT"
    echo "Terminating Execution"
  exit 1

