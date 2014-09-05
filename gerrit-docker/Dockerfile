# gerrit
#
# VERSION               0.0.2

FROM  ubuntu:trusty

MAINTAINER Larry Cai <larry.caiyu@gmail.com>

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
RUN chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME
#RUN rm -f /etc/apt/apt.conf.d/01proxy

USER gerrit
RUN java -jar $GERRIT_WAR init --batch -d $GERRIT_HOME/gerrit

# clobber the gerrit config. set the URL to localhost:8080
ADD gerrit.config $GERRIT_HOME/gerrit/etc/gerrit.config

USER root
EXPOSE 8080 29418
CMD ["/usr/sbin/service","supervisor","start"]
