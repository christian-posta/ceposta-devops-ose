
#Example how to run this:
# docker run -itdP --name=“gerrit” -e “GERRIT_USER=admin” -e “GERRIT_PASSWORD=redhat01” -e \
# “GERRIT_PROJ_ROOT=root”--link gitlab:gitlab gerrit
FROM  ubuntu:trusty

MAINTAINER Christian Posta <christian.posta@gmail.com>

ENV GERRIT_HOME /home/gerrit
ENV GERRIT_USER gerrit
ENV GERRIT_WAR /home/gerrit/gerrit.war

RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list

# comment out the following line if you don't have a local deb proxy
#RUN IPADDR=$( ip route | grep default | awk '{print $3}' ) ;echo "Acquire::http { Proxy \"http://$IPADDR:3142\"; };"| tee -a /etc/apt/apt.conf.d/01proxy

RUN apt-get update
RUN apt-get upgrade

RUN useradd -m ${GERRIT_USER}
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes tzdata=2014b-1 tzdata-java openjdk-6-jre-headless sudo git-core supervisor vim-tiny
RUN mkdir -p /var/log/supervisor

ADD http://gerrit-releases.storage.googleapis.com/gerrit-2.8.5.war /tmp/gerrit.war
#ADD gerrit-2.8.war /tmp/gerrit.war
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p $GERRIT_HOME/gerrit
RUN mv /tmp/gerrit.war $GERRIT_WAR
ADD replication.config $GERRIT_HOME/gerrit/etc/replication.config
ADD conf-and-run-gerrit.sh $GERRIT_HOME/conf-and-run-gerrit.sh
RUN chmod +x $GERRIT_HOME/conf-and-run-gerrit.sh

RUN chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME



USER gerrit
RUN java -jar $GERRIT_WAR init --install-plugin=replication --batch -d $GERRIT_HOME/gerrit

USER root
# clobber the gerrit config. set the URL to localhost:8080
ADD gerrit.config $GERRIT_HOME/gerrit/etc/gerrit.config

# add the databases
ADD db/ReviewDB.h2.db $GERRIT_HOME/gerrit/db/ReviewDB.h2.db
ADD db/ReviewDB.trace.db $GERRIT_HOME/gerrit/db/ReviewDB.trace.db
RUN chmod 644 $GERRIT_HOME/gerrit/db/ReviewDB.h2.db
RUN chmod 644 $GERRIT_HOME/gerrit/db/ReviewDB.trace.db

# add the project settings
ADD git/All-Projects.git/objects/17 $GERRIT_HOME/gerrit/git/All-Projects.git/objects/17
ADD git/All-Projects.git/objects/51 $GERRIT_HOME/gerrit/git/All-Projects.git/objects/51
ADD git/All-Projects.git/objects/1c $GERRIT_HOME/gerrit/git/All-Projects.git/objects/1c
ADD git/All-Projects.git/refs/meta/config $GERRIT_HOME/gerrit/git/All-Projects.git/refs/meta/config
RUN chmod 644 $GERRIT_HOME/gerrit/git/All-Projects.git/refs/meta/config
RUN chmod 755 $GERRIT_HOME/gerrit/git/All-Projects.git/objects/17
RUN chmod 444 $GERRIT_HOME/gerrit/git/All-Projects.git/objects/17/46dd2af0eb865131d635d1756fa7e3589f5a9c
RUN chmod 755 $GERRIT_HOME/gerrit/git/All-Projects.git/objects/51
RUN chmod 444 $GERRIT_HOME/gerrit/git/All-Projects.git/objects/51/6caf53e5e1ef1b1bf7bb5657e26a924f973db7
RUN chmod 755 $GERRIT_HOME/gerrit/git/All-Projects.git/objects/1c
RUN chmod 444 $GERRIT_HOME/gerrit/git/All-Projects.git/objects/1c/b7aceab8421bfb8c117f9cc25d0c8a030f24e8


RUN chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

EXPOSE 8080 29418
CMD ["/home/gerrit/conf-and-run-gerrit.sh"]
