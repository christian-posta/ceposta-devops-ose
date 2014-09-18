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

$FUSE=$1
createDockerUrl `docker port $FUSE 8181`
HAWTIO_URL=$dockerUrl

createDockerUrl `docker port $FUSE 8101`
FUSE_SSH=$dockerUrl

createDockerUrl `docker port $FUSE 1099`
FUSE_JMX=$dockerUrl

createDockerUrl `docker port $FUSE 61616`
FUSE_MQ=$dockerUrl

createDockerUrl `docker port $FUSE 2181`
FUSE_ZK=$dockerUrl


echo "Fuse Hawtio:  http://$HAWTIO_URL/"
echo "Fuse SSH:  http://$FUSE_SSH"
echo "Fuse JMX: http://$FUSE_JMX"
echo "Fuse MQ:   http://$FUSE_MQ"
echo "Fuse ZK:  http://$FUSE_ZK"