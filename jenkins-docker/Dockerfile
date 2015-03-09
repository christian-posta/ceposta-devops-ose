FROM java:openjdk-7u65-jdk

MAINTAINER Christian Posta <christian.posta@gmail.com>

RUN apt-get update && apt-get install -y wget python sshpass maven git curl zip && rm -rf /var/lib/apt/lists/*

ENV JENKINS_HOME /var/jenkins_home

# Jenkins is ran with user `jenkins`, uid = 1000
# If you bind mount a volume from host/vloume from a data container,
# ensure you use same uid
RUN useradd -d "$JENKINS_HOME" -u 1000 -m -s /bin/bash jenkins

RUN mkdir -p "$JENKINS_HOME"
RUN mkdir -p "$JENKINS_HOME"/plugins
RUN mkdir -p "$JENKINS_HOME"/jobs



# could use ADD but this one does not check Last-Modified header
# see https://github.com/docker/docker/issues/8331
RUN curl -L http://mirrors.jenkins-ci.org/war/1.576/jenkins.war -o "$JENKINS_HOME"/jenkins.war
RUN chown jenkins:jenkins "$JENKINS_HOME"/jenkins.war


# Let's install all of the plugins we'll need
# The jenkins site to browse the plugins is here: https://updates.jenkins-ci.org/download/plugins/
ADD plugins/git.hpi /var/jenkins_home/plugins/git.hpi
ADD plugins/ssh-credentials.hpi /var/jenkins_home/plugins/ssh-credentials.hpi
ADD plugins/ssh-agent.hpi /var/jenkins_home/plugins/ssh-agent.hpi
ADD plugins/rebuild.hpi /var/jenkins_home/plugins/rebuild.hpi
ADD plugins/git-client.hpi /var/jenkins_home/plugins/git-client.hpi
ADD plugins/scm-api.hpi /var/jenkins_home/plugins/scm-api.hpi
ADD plugins/ssh-credentials.hpi /var/jenkins_home/plugins/ssh-credentials.hpi
ADD plugins/credentials.hpi /var/jenkins_home/plugins/credentials.hpi
ADD plugins/config-file-provider.hpi /var/jenkins_home/plugins/config-file-provider.hpi
ADD plugins/token-macro.hpi /var/jenkins_home/plugins/token-macro.hpi
ADD plugins/run-condition.hpi /var/jenkins_home/plugins/run-condition.hpi
ADD plugins/conditional-buildstep.hpi /var/jenkins_home/plugins/conditional-buildstep.hpi
ADD plugins/parameterized-trigger.hpi /var/jenkins_home/plugins/parameterized-trigger.hpi
ADD plugins/promoted-builds.hpi /var/jenkins_home/plugins/promoted-builds.hpi
ADD plugins/jquery.hpi /var/jenkins_home/plugins/jquery.hpi
ADD plugins/dashboard-view.hpi /var/jenkins_home/plugins/dashboard-view.hpi
ADD plugins/build-pipeline-plugin.hpi /var/jenkins_home/plugins/build-pipeline-plugin.hpi
ADD plugins/managed-scripts.hpi /var/jenkins_home/plugins/managed-scripts.hpi
ADD plugins/copyartifact.hpi /var/jenkins_home/plugins/copyartifact.hpi
ADD plugins/envinject.hpi /var/jenkins_home/plugins/envinject.hpi
ADD plugins/gerrit-trigger.hpi /var/jenkins_home/plugins/gerrit-trigger.hpi
ADD plugins/ws-cleanup.hpi /var/jenkins_home/plugins/ws-cleanup.hpi
ADD plugins/role-strategy.hpi /var/jenkins_home/plugins/role-strategy.hpi


# add the maven settings.xml
#ADD maven/settings.xml /etc/maven/settings.xml
RUN mkdir -p "$JENKINS_HOME"/.m2
ADD maven/settings.xml /var/jenkins_home/.m2/settings.xml
RUN chown -R jenkins:jenkins "$JENKINS_HOME"/.m2

# add the jenkins jobs
ADD jobs/config.xml /var/jenkins_home/config.xml
ADD jobs/gerrit-trigger.xml /var/jenkins_home/gerrit-trigger.xml
ADD jobs/fuse-rest-deploy-dev/ /var/jenkins_home/jobs/fuse-rest-deploy-dev
ADD jobs/fuse-rest-integration-tests/ /var/jenkins_home/jobs/fuse-rest-integration-tests
ADD jobs/fuse-rest-initial-build/ /var/jenkins_home/jobs/fuse-rest-initial-build
ADD jobs/fuse-rest-gerrit-patchset/ /var/jenkins_home/jobs/fuse-rest-gerrit-patchset
ADD jobs/fuse-rest-dev-acceptance/ /var/jenkins_home/jobs/fuse-rest-dev-acceptance


# change ownership of plugins and projects
RUN chown -R jenkins:jenkins /var/jenkins_home/plugins
RUN chown -R jenkins:jenkins /var/jenkins_home/jobs
RUN chown jenkins:jenkins /var/jenkins_home/config.xml
RUN chown jenkins:jenkins /var/jenkins_home/gerrit-trigger.xml

# configure maven installation
RUN printf "<?xml version='1.0' encoding='UTF-8'?> <hudson.tasks.Maven_-DescriptorImpl> <installations> <hudson.tasks.Maven_-MavenInstallation> <name>maven</name> <home>/usr/share/maven</home> <properties/> </hudson.tasks.Maven_-MavenInstallation> </installations> </hudson.tasks.Maven_-DescriptorImpl>" >> /var/jenkins_home/hudson.tasks.Maven.xml ; chown jenkins:jenkins /var/jenkins_home/hudson.tasks.Maven.xml


ADD conf-and-run-jenkins.sh /home/jenkins/conf-and-run-jenkins.sh
RUN chmod +x /home/jenkins/conf-and-run-jenkins.sh
RUN chown jenkins:jenkins /home/jenkins/conf-and-run-jenkins.sh

RUN mkdir -p "$JENKINS_HOME"/gerrit/keys
ADD ssh-keys/jenkins /var/jenkins_home/gerrit/keys/jenkins
RUN chown -R jenkins:jenkins "$JENKINS_HOME"/gerrit

USER jenkins

# Set up git user 'jenkins'
RUN git config --global user.email "jenkins@jenkins.org"
RUN git config --global user.name "jenkins"

# for main web interface:
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

ENTRYPOINT ["/home/jenkins/conf-and-run-jenkins.sh"]
