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


echo "Building the docker images in $APP_BASE"

echo "building the Docker image for gerrit"
docker build -t fabric8:gerrit $APP_BASE/gerrit-docker

echo "building the Docker image for jenkins"
docker build -t fabric8:jenkins $APP_BASE/jenkins-docker

echo "pulling the Docker image for gitlab"
docker pull sameersbn/gitlab:latest

echo "pulling the Docker image for nexus"
docker pull pantinor/centos-nexus:latest

echo "pulling the Docker image for fabric8"
docker pull fabric8/fabric8:latest

echo "docker images all built and pulled!"
