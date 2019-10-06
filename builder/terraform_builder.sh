#!/bin/bash
#set -x
#This script creates the terraform.tfvars file for the jenkins project
#This script gets the project properties file as input to prepare the terraform.tfvars file
#Execution Syntax: ./terraform_builder.sh <absolute_path_to_valid_property_file_name>
#Execution Example: ./terraform_builder.sh /app/jenkins/properties/sample.properties
#Created By senthil Nathan Manoharan
#Contact : senthil.nathanm@yahoo.com

if [ $# -eq 0 ]; then
    echo "No arguments provided"
    exit 1
fi

#Initialize Files and Variables
PROPERTY_FILE=$1
TERRAFORM_HOME="/app/jenkins/terraform"
IMAGE_FACTORY="/app/jenkins/image_factory"

#Fetch project Name
ProjectName=$(cat ${PROPERTY_FILE} | grep ProjectName | awk -F: '{print $NF}')

#Project Store Creation
mkdir -p ${TERRAFORM_HOME}/$(echo ${ProjectName} | tr '[:upper:]' '[:lower:]')
#Jenkins Home Bind Mount Creation
mkdir -p /jenkins/$(echo ${ProjectName} | tr '[:upper:]' '[:lower:]')
#Copy terraform code for the instance
cp -p ${IMAGE_FACTORY}/tfCode/*.tf ${TERRAFORM_HOME}/$(echo ${ProjectName} | tr '[:upper:]' '[:lower:]')
#Prepare terraform.tfvars file

echo -e "project_name = \"$(echo ${ProjectName} | tr '[:upper:]' '[:lower:]')\"\nimage_name = \"icondockerregistry.com:5000/icon_jenkins_$(echo ${ProjectName} | tr '[:upper:]' '[:lower:]'):latest\"\nweb_interface_port = $(cat ${PROPERTY_FILE} | grep "WebInterfacePort" | awk -F= '{print $NF}')\napi_interface_port = $(cat ${PROPERTY_FILE} | grep "ApiInterfacePort" | awk -F= '{print $NF}')\njenkins_volume = \"/jenkins/$(echo ${ProjectName} | tr '[:upper:]' '[:lower:]')\"" > ${TERRAFORM_HOME}/$(echo ${ProjectName} | tr '[:upper:]' '[:lower:]')/terraform.tfvars

