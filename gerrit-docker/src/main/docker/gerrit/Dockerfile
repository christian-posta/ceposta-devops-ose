# Example how to run this:
# docker run -itdP --name=“gerrit” -e “GERRIT_USER=admin” -e “GERRIT_PASSWORD=redhat01” -e \
# “GERRIT_PROJ_ROOT=root”--link gitlab:gitlab gerrit
FROM ubuntu:trusty

ENV GERRIT_HOME /home/gerrit
ENV GERRIT_USER gerrit
ENV GERRIT_WAR /home/gerrit/gerrit.war

RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list

# comment out the following line if you don't have a local deb proxy
#RUN IPADDR=$( ip route | grep default | awk '{print $3}' ) ;echo "Acquire::http { Proxy \"http://$IPADDR:3142\"; };"| tee -a /etc/apt/apt.conf.d/01proxy

RUN apt-get update
RUN apt-get upgrade -y

RUN useradd -m ${GERRIT_USER}
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes tzdata=2014b-1 tzdata-java openjdk-6-jre-headless sudo git-core supervisor vim-tiny
RUN mkdir -p /var/log/supervisor

ADD https://gerrit-releases.storage.googleapis.com/gerrit-2.8.5.war /tmp/gerrit.war
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p $GERRIT_HOME/gerrit && mkdir -p ${GERRIT_HOME}/gerrit/plugins
RUN mv /tmp/gerrit.war $GERRIT_WAR
ADD replication.config $GERRIT_HOME/gerrit/etc/replication.config
ADD conf-and-run-gerrit.sh $GERRIT_HOME/conf-and-run-gerrit.sh
RUN chmod +x $GERRIT_HOME/conf-and-run-gerrit.sh

RUN chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

# Download gerrit plugin
ADD http://ci.gerritforge.com/view/Plugins-stable-2.9/job/Plugin_delete-project_stable-2.9/lastSuccessfulBuild/artifact/target/delete-project-2.9.jar ${GERRIT_HOME}/gerrit/plugins/delete-project.jar

USER gerrit
RUN java -jar $GERRIT_WAR init --install-plugin=replication --batch -d $GERRIT_HOME/gerrit

USER root
# clobber the gerrit config. set the URL to localhost:8080
ADD gerrit.config $GERRIT_HOME/gerrit/etc/gerrit.config

# add the databases
## leaving out for now until we can figure out how to autmoate the
## admin user
#ADD db/ReviewDB.h2.db $GERRIT_HOME/gerrit/db/ReviewDB.h2.db
#RUN chmod 644 $GERRIT_HOME/gerrit/db/ReviewDB.h2.db

RUN chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

EXPOSE 8080 29418
CMD ["/home/gerrit/conf-and-run-gerrit.sh"]
