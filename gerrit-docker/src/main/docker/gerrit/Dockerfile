FROM ubuntu:14.04

MAINTAINER Fabric8 <info@fabric8.io>

ENV GERRIT_HOME /home/gerrit
ENV GERRIT_ROOT /home/gerrit/gerrit
ENV GERRIT_USER gerrit
ENV GERRIT_WAR /home/gerrit/gerrit.war
ENV GERRIT_VERSION 2.11

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get -y upgrade && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y sudo vim-tiny git && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-7-jre-headless
  
# Install gosu - Version 1.4
# ADD https://github.com/tianon/gosu/releases/download/1.4/gosu-amd64 /usr/local/bin/gosu
# RUN chmod +x /usr/local/bin/gosu

# Add user gerrit & group like also gerrit to sudo to allow the gerrit user to issue a sudo cmd
RUN groupadd -r $GERRIT_USER && useradd -r -g $GERRIT_USER $GERRIT_USER && adduser gerrit sudo

RUN mkdir -p ${GERRIT_HOME}/gerrit/plugins

ADD http://gerrit-releases.storage.googleapis.com/gerrit-${GERRIT_VERSION}.war $GERRIT_WAR

ADD replication.config $GERRIT_HOME/gerrit/etc/replication.config
ADD conf-and-run-gerrit.sh $GERRIT_HOME/conf-and-run-gerrit.sh
RUN chmod +x $GERRIT_HOME/conf-and-run-gerrit.sh

# Download gerrit plugin
ADD http://ci.gerritforge.com/view/Plugins-stable-2.9/job/Plugin_delete-project_stable-2.9/lastSuccessfulBuild/artifact/target/delete-project-2.9.jar ${GERRIT_HOME}/gerrit/plugins/delete-project.jar

RUN chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

USER gerrit
# CMD ["/usr/bin/ls","/home/gerrit"]
WORKDIR $GERRIT_HOME
RUN java -jar $GERRIT_WAR init --install-plugin=replication --batch -d $GERRIT_ROOT
RUN java -jar $GERRIT_WAR reindex -d $GERRIT_ROOT

ADD gerrit.config $GERRIT_HOME/gerrit/etc/gerrit.config

ENV AUTH_TYPE DEVELOPMENT_BECOME_ANY_ACCOUNT

# USER root

EXPOSE 8080 29418
CMD ["/home/gerrit/conf-and-run-gerrit.sh"]
