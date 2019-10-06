#!/bin/bash
cp -p /tmp/jenkins.war /usr/share/jenkins/jenkins.war
cp -p /tmp/install-plugins.sh /usr/local/bin/install-plugins.sh
cp -p /tmp/plugins.txt /usr/share/jenkins/ref/plugins.txt
cp -pr /tmp/users/ /var/jenkins_home/users
rm -Rf /usr/share/jenkins/ref/plugins/*lock
xargs /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
cp -p /tmp/jenkins_home_config.xml /var/jenkins_home/jenkins_home_config.xml
chown -Rf jenkins:jenkins /var/jenkins_home/
