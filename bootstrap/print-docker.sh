#!/bin/sh
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