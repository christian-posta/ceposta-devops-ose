#!/bin/sh

DOCKER_HOSTNAME=${DOCKER_HOSTNAME:-`echo $DOCKER_HOST | awk '{gsub("(tcp|http)://|/.*","")}1' | awk '{gsub(":.*","")}1'`}
if [ -z "$APP_BASE" ] ; then
  DOCKER_HOSTNAME="localhost"
fi

echo "Docker host name is $DOCKER_HOSTNAME"

createDockerUrl() {
  dockerUrl=`echo $1 | sed s/0.0.0.0/$DOCKER_HOSTNAME/`
}


createDockerUrl `docker port gerrit 8080`
GERRIT_URL=$dockerUrl

createDockerUrl `docker port gitlab 80`
GITLAB_URL=$dockerUrl

createDockerUrl `docker port jenkins 8080`
JENKINS_URL=$dockerUrl

createDockerUrl `docker port nexus 8081`
NEXUS_URL=$dockerUrl

echo "Gerrit:  http://$GERRIT_URL/"
echo "Gitlab:  http://$GITLAB_URL/"
echo "Jenkins: http://$JENKINS_URL/"
echo "Nexus:   http://$NEXUS_URL/nexus"