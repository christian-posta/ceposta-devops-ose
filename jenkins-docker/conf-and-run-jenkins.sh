#!/bin/bash

# Build jobs
find /var/jenkins_home/jobs -name \*.xml | xargs sed -i  's/__GITLAB_IP__/'${GITLAB_PORT_80_TCP_ADDR}'/g'
find /var/jenkins_home/jobs -name \*.xml | xargs sed -i  's/__NEXUS_IP__/'${NEXUS_PORT_8081_TCP_ADDR}'/g'
find /var/jenkins_home/jobs -name \*.xml | xargs sed -i  's/__NEXUS_PORT__/'${NEXUS_PORT_8081_TCP_PORT}'/g'
find /var/jenkins_home/jobs -name \*.xml | xargs sed -i  's/__GERRIT_IP__/'${GERRIT_PORT_8080_TCP_ADDR}'/g'

# Global configs
sed -i  's/__GERRIT_IP__/'${GERRIT_PORT_8080_TCP_ADDR}'/g' /var/jenkins_home/gerrit-trigger.xml
sed -i  's/__NEXUS_IP__/'${NEXUS_PORT_8081_TCP_ADDR}'/g' /usr/share/maven/conf/settings.xml
sed -i  's/__NEXUS_PORT__/'${NEXUS_PORT_8081_TCP_PORT}'/g' /usr/share/maven/conf/settings.xml

. /usr/local/bin/jenkins.sh