#!/bin/sh

set -e

cp -R ${GERRIT_TMP_DIR}/site ${GERRIT_SITE}
cp ${GERRIT_TMP_DIR}/${GERRIT_WAR} ${GERRIT_HOME}/${GERRIT_WAR}

# Configure Git Replication
sed -i  's/__GIT_SERVER_IP__/'${GIT_SERVER_IP}'/g' /home/gerrit/site/etc/replication.config
sed -i  's/__GIT_SERVER_USER__/'${GIT_SERVER_USER}'/g' /home/gerrit/site/etc/replication.config
sed -i  's/__GIT_SERVER_PASSWORD__/'${GIT_SERVER_PASSWORD}'/g' /home/gerrit/site/etc/replication.config
sed -i  's/__GIT_SERVER_PROJ_ROOT__/'${GIT_SERVER_PROJ_ROOT}'/g' /home/gerrit/site/etc/replication.config

# Configure Gerrit
sed -i  's/__AUTH_TYPE__/'${AUTH_TYPE}'/g' /home/gerrit/site/etc/gerrit.config

# Change permissions here as all the files created by docker within the image
# have root as user and root as group defined even after applying the instructions
# RUN chown -R ${GERRIT_USER}:${GERRIT_USER} ${GERRIT_HOME} && \
#     chown -R ${GERRIT_USER}:${GERRIT_USER} ${GERRIT_TMP_DIR}
chown -R gerrit:gerrit $GERRIT_HOME

# ls -la -R /home/gerrit

# Start gerrit

# Reset the gerrit_war variable as the path must be defined to the /home/gerrit/ directory
export GERRIT_WAR=${GERRIT_HOME}/gerrit.war

# Error reported when we launch gerrit with the bash script
# /home/gerrit/site/bin/gerrit.sh: line 429: echo: write error: Permission denied
# ${GERRIT_HOME}/site/bin/gerrit.sh start
# 
# To debug it, run this command after starting the container intereactive mode
# docker run -it -p 0.0.0.0:8080:8080 -p 127.0.0.1:29418:29418 --name my-gerrit cmoulliard/gerrit:1.0 bash
# bash -x ${GERRIT_HOME}/site/bin/gerrit.sh start

echo "Gerrit started using the java cmd : java -jar ${GERRIT_WAR} daemon -d ${GERRIT_SITE}"
exec java -jar ${GERRIT_WAR} daemon -d ${GERRIT_SITE}


# if [ $? -eq 0 ]
# then
#     echo "gerrit $GERRIT_VERSION is started successfully with auth.type=$AUTH_TYPE, please login to check."
# 	echo ""
# 	tail -f $GERRIT_HOME/site/logs/httpd_log
# else
#     cat $GERRIT_HOME/site/logs/error_log
# fi

# cat /home/gerrit/site/etc/replication.config
# cat /home/gerrit/site/etc/gerrit.config
# Add ssh key imported by Kubernetes to access gogs
# RUN echo "Host Gogs" >> /etc/ssh/ssh_config
# RUN echo "Hostname gogs-http-service.default.local" >> /etc/ssh/ssh_config
# RUN echo "IdentityFile /etc/secret-volume/id-rsa" >> /etc/ssh/ssh_config