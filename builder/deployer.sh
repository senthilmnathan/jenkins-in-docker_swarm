#!/bin/bash
#set -x
#This is the final stage in jenkins container deployment
#This script uses the artifacts generated in the previous stages and deploys  the container via terraform
#Execution Syntax: ./deployer.sh <absolute_path_to_valid_property_file_name>
#Execution Example: ./deployer.sh /app/jenkins/properties/sample.properties
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
#Fetch project Name
ProjectName=$(cat ${PROPERTY_FILE} | grep ProjectName | awk -F: '{print $NF}' | tr '[:upper:]' '[:lower:]')
cd ${TERRAFORM_HOME}/${ProjectName}
terraform init -reconfigure
if [ $? -ne 0 ]
then
  echo "Terraform Initialization Failed"
  echo "Cannot Proceed Further"
  echo "Terminating Execution"
  exit 1
fi
terraform validate
if [ $? -ne 0 ]
then
  echo "Terraform Validation Failed"
  echo "Cannot Proceed Further"
  echo "Terminating Execution"
  exit 1
fi
terraform plan -out=tfplan
if [ $? -ne 0 ]
then
  echo "Terraform Plan Failed"
  echo "Cannot Proceed Further"
  echo "Terminating Execution"
  exit 1
else
  echo "Terraform Plan Has Succeeded"
  echo "Review the plan output for a list of all resources being created"
  while true
  do
    read -p "Do you wish to proceed with deplpying the instance        (Y/N):" choice
    case ${choice} in
      [Yy]* ) 
        terraform apply "tfplan"
        if [ $? -ne 0 ]
        then
          echo "Terraform Apply Failed"
          echo "Review Console Output for specific error messages"
          echo "Terminating Execution"
         exit 1

        else
          echo "Terraform Apply Succeeded"
         exit 0
        fi
      ;;
      [Nn]* )
        echo "Not deploying resources"
        echo "Terminating Execution"
        exit 0
      ;;
      * )
        echo "Invalid Input"
        echo "Terminating Execution"
        exit 0
      ;;
    esac
  done
fi
