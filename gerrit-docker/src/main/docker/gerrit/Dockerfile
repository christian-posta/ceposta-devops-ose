FROM ubuntu:14.04

MAINTAINER Fabric8 <info@fabric8.io>

ENV GERRIT_HOME /home/gerrit
ENV GERRIT_SITE /home/gerrit/site
ENV GERRIT_TMP_DIR /home/tmp
ENV GERRIT_USER gerrit
ENV GERRIT_WAR gerrit.war
ENV GERRIT_VERSION 2.11

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get -y upgrade && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y sudo vim-tiny git && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-7-jre-headless && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y curl
  
# Install gosu - Version 1.4 - DOESN'T WORK
# ADD https://github.com/tianon/gosu/releases/download/1.4/gosu-amd64 /usr/local/bin/gosu
# RUN chmod +x /usr/local/bin/gosu

# Add user gerrit & group like also gerrit to sudo to allow the gerrit user to issue a sudo cmd
RUN groupadd $GERRIT_USER && \
    useradd -r -u 1000 -g $GERRIT_USER $GERRIT_USER

RUN mkdir ${GERRIT_HOME}

# Download Gerrit
ADD http://gerrit-releases.storage.googleapis.com/gerrit-${GERRIT_VERSION}.war ${GERRIT_HOME}/${GERRIT_WAR}

# Copy the files to bin folder
ADD ./bin ${GERRIT_HOME}/bin
RUN chmod +x ${GERRIT_HOME}/bin/conf-and-run-gerrit.sh

WORKDIR ${GERRIT_HOME}

EXPOSE 8080 29418
CMD ["/home/gerrit/bin/conf-and-run-gerrit.sh"]
