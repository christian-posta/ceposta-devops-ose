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

RUN useradd -m $GERRIT_USER
RUN mkdir -p $GERRIT_HOME
RUN chown ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

RUN mkdir -p /var/log/supervisor

ADD http://gerrit-releases.storage.googleapis.com/gerrit-${GERRIT_VERSION}.war $GERRIT_WAR
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p ${GERRIT_HOME}/gerrit/plugins

ADD replication.config $GERRIT_HOME/gerrit/etc/replication.config
ADD conf-and-run-gerrit.sh $GERRIT_HOME/conf-and-run-gerrit.sh
RUN chmod +x $GERRIT_HOME/conf-and-run-gerrit.sh

# Download gerrit plugin
ADD http://ci.gerritforge.com/view/Plugins-stable-2.9/job/Plugin_delete-project_stable-2.9/lastSuccessfulBuild/artifact/target/delete-project-2.9.jar ${GERRIT_HOME}/gerrit/plugins/delete-project.jar

RUN chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

USER gerrit
CMD ["/usr/bin/ls","/home/gerrit"]
RUN java -jar $GERRIT_WAR init --install-plugin=replication --batch -d $GERRIT_ROOT
RUN java -jar $GERRIT_WAR reindex -d $GERRIT_ROOT

ADD gerrit.config $GERRIT_HOME/gerrit/etc/gerrit.config

USER root

# Add ssh key imported by Kubernetes to access gogs
RUN echo "Host Gogs" >> /etc/ssh/ssh_config
RUN echo "Hostname gogs.vagrant.local" >> /etc/ssh/ssh_config
RUN echo "IdentityFile /etc/secret-volume/id-rsa" >> /etc/ssh/ssh_config

ENV AUTH_TYPE DEVELOPMENT_BECOME_ANY_ACCOUNT

EXPOSE 8080 29418
CMD ["/home/gerrit/conf-and-run-gerrit.sh"]
