#!/bin/sh

set -e

# Initialize gerrit & reindex the site if the directory doesn't exist
if [ ! -d "$GERRIT_HOME/site" ]; then

  mkdir -p site/plugins
  
  echo ">> Site doesn't exist. We will start gerrit to generate it"
  java -jar ${GERRIT_HOME}/$GERRIT_WAR init --install-plugin=replication --batch -d ${GERRIT_HOME}/site
  java -jar ${GERRIT_HOME}/$GERRIT_WAR reindex -d ${GERRIT_HOME}/site
  
  # Download Gerrit plugin
  echo ">> Download gerrit plugins - delete project <<"
  curl -sSL http://ci.gerritforge.com/view/Plugins-stable-2.10/job/Plugin_delete-project_stable-2.10/lastSuccessfulBuild/artifact/target/delete-project-2.10.jar -o ${GERRIT_HOME}/site/plugins/delete-project.jar

  # Copy our config files
  cp bin/gerrit.config ${GERRIT_HOME}/site/etc/gerrit.config
  cp bin/replication.config ${GERRIT_HOME}/site/etc/replication.config
  
  # Configure Git Replication
  sed -i  's/__GIT_SERVER_IP__/'${GIT_SERVER_IP}'/g' ${GERRIT_HOME}/site/etc/replication.config
  sed -i  's/__GIT_SERVER_PORT__/'${GIT_SERVER_PORT}'/g' ${GERRIT_HOME}/site/etc/replication.config
  sed -i  's/__GIT_SERVER_USER__/'${GIT_SERVER_USER}'/g' ${GERRIT_HOME}/site/etc/replication.config
  sed -i  's/__GIT_SERVER_PASSWORD__/'${GIT_SERVER_PASSWORD}'/g' ${GERRIT_HOME}/site/etc/replication.config
  sed -i  's/__GIT_SERVER_PROJ_ROOT__/'${GIT_SERVER_PROJ_ROOT}'/g' ${GERRIT_HOME}/site/etc/replication.config

  # Configure Gerrit
  sed -i  's/__AUTH_TYPE__/'${AUTH_TYPE}'/g' ${GERRIT_HOME}/site/etc/gerrit.config
fi

# Debug purpose
# ls -la $GERRIT_HOME/site/db
# ls -la $GERRIT_HOME/site/etc
# cat /home/gerrit/site/etc/replication.config
# cat /home/gerrit/site/etc/gerrit.config

# Start gerrit

# Reset the gerrit_war variable as the path must be defined to the /home/gerrit/ directory
export GERRIT_WAR=${GERRIT_HOME}/gerrit.war
chown -R gerrit:gerrit $GERRIT_HOME

# Error reported when we launch gerrit with the bash script
# /home/gerrit/site/bin/gerrit.sh: line 429: echo: write error: Permission denied
# ${GERRIT_HOME}/site/bin/gerrit.sh start
# 
# To debug it, run this command after starting the container intereactive mode
# docker run -it -p 0.0.0.0:8080:8080 -p 127.0.0.1:29418:29418 --name my-gerrit cmoulliard/gerrit:1.0 bash
# bash -x ${GERRIT_HOME}/site/bin/gerrit.sh start

echo "Gerrit started using the java cmd : java -jar ${GERRIT_WAR} daemon -d ${GERRIT_SITE}"
exec java -jar ${GERRIT_WAR} daemon -d ${GERRIT_SITE}
