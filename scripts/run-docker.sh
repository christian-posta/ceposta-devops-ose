#!/bin/bash

set -e


#
# Discover the APP_BASE from the location of this script.
#
if [ -z "$APP_BASE" ] ; then
  ## resolve links - $0 may be a link to apollo's home
  PRG="$0"
  saveddir=`pwd`

  # need this for relative symlinks
  dirname_prg=`dirname "$PRG"`
  cd "$dirname_prg"

  while [ -h "$PRG" ] ; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '.*/.*' > /dev/null; then
      PRG="$link"
    else
      PRG=`dirname "$PRG"`"/$link"
    fi
  done

  APP_BASE=`dirname "$PRG"`
  cd "$saveddir"

  # make it fully qualified
  APP_BASE=`cd "$APP_BASE/.." && pwd`
  export APP_BASE
fi

# environment variables
GITLAB_USER=${GITLAB_USER:-root}
GITLAB_PASSWORD=${GITLAB_PASSWORD:-redhat01}
GITLAB_PROJ_ROOT=${GITLAB_PROJ_ROOT:-root}

DOCKER_HOSTNAME=${DOCKER_HOSTNAME:-`echo $DOCKER_HOST | awk '{gsub("(tcp|http)://|/.*","")}1' | awk '{gsub(":.*","")}1'`}
if [ -z "$APP_BASE" ] ; then
  DOCKER_HOSTNAME="localhost"
fi

echo "Docker host name is $DOCKER_HOSTNAME"

createDockerUrl() {
  dockerUrl=`echo $1 | sed s/0.0.0.0/$DOCKER_HOSTNAME/`
}

echo "Creating the docker images using gitlab user ${GITLAB_USER} and project root ${GITLAB_PROJ_ROOT}"
docker run -itdP --name gitlab -e 'GITLAB_SIGNUP=true' sameersbn/gitlab:latest
docker run -itdP --name nexus pantinor/centos-nexus:latest
docker run -itdP --name gerrit --env GITLAB_USER=$GITLAB_USER --env GITLAB_PASSWORD=$GITLAB_PASSWORD --env GITLAB_PROJ_ROOT=$GITLAB_PROJ_ROOT --link gitlab:gitlab fabric8:gerrit
docker run -itdP --name jenkins --link gitlab:gitlab --link nexus:nexus fabric8:jenkins

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
