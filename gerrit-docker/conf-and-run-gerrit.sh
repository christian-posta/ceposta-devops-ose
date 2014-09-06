#!/bin/sh

sed -i  's/__GITLAB_IP__/'${GITLAB_PORT_80_TCP_ADDR}'/g' $GERRIT_HOME/gerrit/etc/replication.config

. /home/gerrit/gerrit/bin/gerrit.sh start