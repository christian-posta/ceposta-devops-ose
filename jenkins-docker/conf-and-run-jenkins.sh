#!/bin/bash

find /var/jenkins_home/jobs -name config.xml | xargs sed -i  's/__GITLAB_IP__/'${GITLAB_PORT_80_TCP_ADDR}'/g'
find /var/jenkins_home/jobs -name config.xml | xargs sed -i  's/__NEXUS_IP__/'${NEXUS_PORT_8081_TCP_ADDR}'/g'
find /var/jenkins_home/jobs -name config.xml | xargs sed -i  's/__NEXUS_PORT__/'${NEXUS_PORT_8081_TCP_PORT}'/g'

. /usr/local/bin/jenkins.sh