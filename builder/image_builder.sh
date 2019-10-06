#!/bin/bash
set -x
#This script must be used to generate customized versions of Jenkins Docker Images
#A Custom Docker Image is created for each project team 
#This script pulls values from project specific property file
#Execution Syntax: ./image_builder.sh <absolute_path_to_valid_property_file_name>
#Execution Example: ./image_builder.sh /app/jenkins/properties/sample.properties
#Created By senthil Nathan Manoharan
#Contact : senthil.nathanm@yahoo.com

#Input Parameter Validation
propertyFileValidation()
{
  #Property File Validation
  echo "wall"
}

#Package Install Segment
pkgInstSegment()
{
  #Package Install segment
  pack="git curl"
  for pkg in "${packageList[@]}"
  do
    pack="${pack} ${pkg}"
  done
  sed -i "s|git curl|${pack}|g" ${IMAGE_FACTORY}/image_base/Dockerfile
}

#Python Library Install Segment
pytLibInstSegment()
{
  #Add check for python library in Dockerfile later
  library=""
  for lib in "${PythonLibraryList[@]}"
  do
    library="${library} ${lib}"
  done 
  sed -i "s|.*RUN apt-get.*|&\nRUN pip install --upgrade pip ${library}|g" ${IMAGE_FACTORY}/image_base/Dockerfile
}

#Plugin File Update Segment
pluginSegment()
{
  for plugin in "${PluginList[@]}"
  do
    if [ -z $(cat ${IMAGE_FACTORY}/image_base/plugins.txt | grep "${plugin}") ]
    then
      echo -e "${plugin}\n" >> ${IMAGE_FACTORY}/image_base/plugins.txt
    fi
  done
}

#Jenkins Admin User Config File Update Segment
admCredUpdate()
{
  adminpassword=$(cat ${PROPERTY_FILE} | grep adminpassword | awk -F: '{print $NF}')  
  origPwd=$(cat ${IMAGE_FACTORY}/image_base/users/admin/config.xml | grep "passwordHash"  | awk -F: '{print $NF}' | awk -F"<" '{print $1}')
  pwdHash=$(echo -n "${adminpassword}{#jbcrypt}" | sha256sum | awk '{print $1}')  
  sed -i "s|${origPwd}|${pwdHash}|g" ${IMAGE_FACTORY}/image_base/users/admin/config.xml
}


#Main Function Block
if [ $# -eq 0 ]; then
    echo "No arguments provided"
    exit 1
fi

#Initialize Files and Variables
PROPERTY_FILE=$1
TERRAFORM_HOME="/app/jenkins/terraform"
IMAGE_FACTORY="/app/jenkins/image_factory"
cp -p ${IMAGE_FACTORY}/image_base/Dockerfile ${IMAGE_FACTORY}/image_base/Dockerfile.orig
cp -p ${IMAGE_FACTORY}/image_base/plugins.txt ${IMAGE_FACTORY}/image_base/plugins.txt.orig
cp -p ${IMAGE_FACTORY}/image_base//users/admin/config.xml ${IMAGE_FACTORY}/image_base//users/admin/config.xml.orig

#Fetch project Name
ProjectName=$(cat ${PROPERTY_FILE} | grep ProjectName | awk -F: '{print $NF}')

#Package Section
IFS=',' read -r -a packageList <<< "$(cat ${PROPERTY_FILE} | grep PackageList | awk -F: '{print $NF}')"
if [ ${#packageList[@]} -gt 0 ]
then
  pkgInstSegment
fi

#Python Library Section
IFS=',' read -r -a PythonLibraryList <<< "$(cat ${PROPERTY_FILE} | grep PythonLibraryList | awk -F: '{print $NF}')"
if [ ${#PythonLibraryList[@]} -gt 0 ]
then
  pytLibInstSegment
fi

#Jenkins Plugin Section
IFS=',' read -r -a PluginList <<< "$(cat ${PROPERTY_FILE} | grep PluginList | awk -F"PluginList:" '{print $NF}')"
if [ ${#PluginList[@]} -gt 0 ]
then
pluginSegment
fi

#Jenkins Admin User Credential Section
admCredUpdate

####################Jenkins Image Build Section####################
cd ${IMAGE_FACTORY}/image_base/
pName=$(echo ${ProjectName} | tr '[:upper:]' '[:lower:]')
docker build --no-cache -t "icon_jenkins_${pName}:latest" . 1>>${IMAGE_FACTORY}/builds/${pName}_build.log 2>>${IMAGE_FACTORY}/builds/${pName}_build.log
if [ $? -ne 0 ]
then
  echo "Image Build Failed"
  echo "Review "${IMAGE_FACTORY}/builds/${pName}_build.log" for error details"
  exit 1
fi
####################Jenkins Image Build Section####################

####################Publish Image to Docker Registry####################
docker tag icon_jenkins_${pName}:latest icondockerregistry.com:5000/icon_jenkins_${pName}
if [ $? -ne 0 ]
then
  echo "Tagging Image to Docker Registry Failed"
  echo "Terminating Execution"
  exit 1
fi
docker push icondockerregistry.com:5000/icon_jenkins_${pName}
if [ $? -ne 0 ]
then
  echo "Publishing Image in Docker Registry Failed"
  echo "Terminating Execution"
  exit 1
fi
####################Publish Image to Docker Registry####################

#FileSystem CleanUp
mv -f ${IMAGE_FACTORY}/image_base/users/admin/config.xml.orig ${IMAGE_FACTORY}/image_base/users/admin/config.xml
mv -f ${IMAGE_FACTORY}/image_base/plugins.txt.orig ${IMAGE_FACTORY}/image_base/plugins.txt
mv -f ${IMAGE_FACTORY}/image_base/Dockerfile.orig ${IMAGE_FACTORY}/image_base/Dockerfile
