#!/bin/sh

# Configure Git Replication
sed -i  's/__GITLAB_IP__/'${GITLAB_PORT_80_TCP_ADDR}'/g' /home/gerrit/gerrit/etc/replication.config
sed -i  's/__GITLAB_USER__/'${GITLAB_USER}'/g' /home/gerrit/gerrit/etc/replication.config
sed -i  's/__GITLAB_PASSWORD__/'${GITLAB_PASSWORD}'/g' /home/gerrit/gerrit/etc/replication.config
sed -i  's/__GITLAB_PROJ_ROOT__/'${GITLAB_PROJ_ROOT}'/g' /home/gerrit/gerrit/etc/replication.config

# Configure Gerrit
sed -i  's/__AUTH_TYPE__/'${AUTH_TYPE}'/g' /home/gerrit/gerrit/etc/gerrit.config

# Add ssh key imported by Kubernetes to access gogs
# RUN echo "Host Gogs" >> /etc/ssh/ssh_config
# RUN echo "Hostname gogs-http-service.default.local" >> /etc/ssh/ssh_config
# RUN echo "IdentityFile /etc/secret-volume/id-rsa" >> /etc/ssh/ssh_config

# Change permissions 
chown -R gerrit $GERRIT_HOME/gerrit
# exec gosu gerrit "/bin/bash -c '/home/gerrit/gerrit/bin/gerrit.sh' start"

# Start gerrit
$GERRIT_HOME/gerrit/bin/gerrit.sh start

if [ $? -eq 0 ]
then
    echo "gerrit $GERRIT_VERSION is started successfully with auth.type=$AUTH_TYPE, please login to check."
	echo ""
	tail -f $GERRIT_HOME/gerrit/logs/httpd_log
else
    cat $GERRIT_HOME/gerrit/logs/error_log
fi