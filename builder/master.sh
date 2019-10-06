#!/bin/bash
#set -x
#This script encapsulates all the other scripts
#Always use this script for deploying any containers in the server
#Execution Syntax: ./master.sh <absolute_path_to_valid_property_file_name>
#Execution Example: ./master.sh /app/jenkins/properties/sample.properties
sh /app/jenkins/builder/image_builder.sh $1
if [ $? -ne 0 ]
then
  echo "Image Build Failed"
  exit 1
fi
sh /app/jenkins/builder/terraform_builder.sh $1
if [ $? -ne 0 ]
then
  echo "Terraform Code Build Failed"
  exit 1
fi
sh /app/jenkins/builder/deployer.sh $1
if [ $? -ne 0 ]
then
  echo "Terraform Deployment Failed"
  exit 1
fi

