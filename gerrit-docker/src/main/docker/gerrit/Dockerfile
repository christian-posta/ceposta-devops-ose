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
  DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-7-jre-headless
  
# Install gosu - Version 1.4
ADD https://github.com/tianon/gosu/releases/download/1.4/gosu-amd64 /usr/local/bin/gosu
RUN chmod +x /usr/local/bin/gosu

# Add user gerrit & group like also gerrit to sudo to allow the gerrit user to issue a sudo cmd
RUN groupadd -r $GERRIT_USER && \
    useradd -r -u 1000 -g $GERRIT_USER $GERRIT_USER && \
    adduser gerrit sudo

RUN mkdir -p ${GERRIT_HOME} && \
    mkdir -p ${GERRIT_TMP_DIR}/site/plugins

# Download Gerrit
ADD http://gerrit-releases.storage.googleapis.com/gerrit-${GERRIT_VERSION}.war ${GERRIT_TMP_DIR}/${GERRIT_WAR}

# Initialize gerrit & reindex the site 
RUN java -jar ${GERRIT_TMP_DIR}/$GERRIT_WAR init --install-plugin=replication --batch -d ${GERRIT_TMP_DIR}/site
RUN java -jar ${GERRIT_TMP_DIR}/$GERRIT_WAR reindex -d ${GERRIT_TMP_DIR}/site

# Download Gerrit plugin
ADD http://ci.gerritforge.com/view/Plugins-stable-2.9/job/Plugin_delete-project_stable-2.9/lastSuccessfulBuild/artifact/target/delete-project-2.9.jar ${GERRIT_TMP_DIR}/site/plugins/delete-project.jar

# Copy our config files
ADD gerrit.config ${GERRIT_TMP_DIR}/site/etc/gerrit.config
ADD replication.config ${GERRIT_TMP_DIR}/site/etc/replication.config

# Copy the shell script used to launch gerrit
ADD conf-and-run-gerrit.sh ${GERRIT_HOME}/conf-and-run-gerrit.sh
RUN chmod +x ${GERRIT_HOME}/conf-and-run-gerrit.sh

#RUN chown -R ${GERRIT_USER}:${GERRIT_USER} ${GERRIT_HOME} && \
#    chown -R ${GERRIT_USER}:${GERRIT_USER} ${GERRIT_TMP_DIR}

WORKDIR ${GERRIT_HOME}

EXPOSE 8080 29418
CMD ["/home/gerrit/conf-and-run-gerrit.sh"]
