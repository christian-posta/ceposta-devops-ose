FROM jenkins:1.576

MAINTAINER Christian Posta <christian.posta@gmail.com>




# Let's install all of the plugins we'll need
# The jenkins site to browse the plugins is here: https://updates.jenkins-ci.org/download/plugins/
ADD http://updates.jenkins-ci.org/latest/git.hpi /var/jenkins_home/plugins/git.hpi
ADD http://updates.jenkins-ci.org/latest/ssh-credentials.hpi /var/jenkins_home/plugins/ssh-credentials.hpi
ADD http://updates.jenkins-ci.org/latest/ssh-agent.hpi /var/jenkins_home/plugins/ssh-agent.hpi
ADD http://updates.jenkins-ci.org/latest/rebuild.hpi /var/jenkins_home/plugins/rebuild.hpi
ADD http://updates.jenkins-ci.org/latest/git-client.hpi /var/jenkins_home/plugins/git-client.hpi
ADD http://updates.jenkins-ci.org/latest/scm-api.hpi /var/jenkins_home/plugins/scm-api.hpi
ADD http://updates.jenkins-ci.org/latest/ssh-credentials.hpi /var/jenkins_home/plugins/ssh-credentials.hpi
ADD http://updates.jenkins-ci.org/latest/credentials.hpi /var/jenkins_home/plugins/credentials.hpi
ADD http://updates.jenkins-ci.org/latest/config-file-provider.hpi /var/jenkins_home/plugins/config-file-provider.hpi
ADD http://updates.jenkins-ci.org/latest/token-macro.hpi /var/jenkins_home/plugins/token-macro.hpi
ADD http://updates.jenkins-ci.org/latest/run-condition.hpi /var/jenkins_home/plugins/run-condition.hpi
ADD http://updates.jenkins-ci.org/latest/conditional-buildstep.hpi /var/jenkins_home/plugins/conditional-buildstep.hpi
ADD http://updates.jenkins-ci.org/latest/parameterized-trigger.hpi /var/jenkins_home/plugins/parameterized-trigger.hpi
ADD http://updates.jenkins-ci.org/latest/promoted-builds.hpi /var/jenkins_home/plugins/promoted-builds.hpi
ADD http://updates.jenkins-ci.org/latest/jquery.hpi /var/jenkins_home/plugins/jquery.hpi
ADD http://updates.jenkins-ci.org/latest/dashboard-view.hpi /var/jenkins_home/plugins/dashboard-view.hpi
ADD http://updates.jenkins-ci.org/latest/build-pipeline-plugin.hpi /var/jenkins_home/plugins/build-pipeline-plugin.hpi
ADD http://updates.jenkins-ci.org/latest/managed-scripts.hpi /var/jenkins_home/plugins/managed-scripts.hpi
ADD http://updates.jenkins-ci.org/latest/copyartifact.hpi /var/jenkins_home/plugins/copyartifact.hpi
ADD http://updates.jenkins-ci.org/latest/envinject.hpi /var/jenkins_home/plugins/envinject.hpi
ADD http://updates.jenkins-ci.org/latest/gerrit-trigger.hpi /var/jenkins_home/plugins/gerrit-trigger.hpi

USER root

# needed to run our OSE scripts
RUN apt-get update && apt-get install -y python

# add the maven settings.xml
ADD maven/settings.xml /etc/maven/settings.xml

# add the jenkins jobs
ADD jobs/config.xml /var/jenkins_home/config.xml
ADD jobs/fuse-rest-deploy-dev/ /var/jenkins_home/jobs/fuse-rest-deploy-dev
ADD jobs/fuse-rest-integration-tests/ /var/jenkins_home/jobs/fuse-rest-integration-tests
ADD jobs/fuse-rest-initial-build/ /var/jenkins_home/jobs/fuse-rest-initial-build


# change ownership of plugins and projects
RUN chown -R jenkins:jenkins /var/jenkins_home/plugins
RUN chown -R jenkins:jenkins /var/jenkins_home/jobs
RUN chown jenkins:jenkins /var/jenkins_home/config.xml

# configure maven installation
RUN printf "<?xml version='1.0' encoding='UTF-8'?> <hudson.tasks.Maven_-DescriptorImpl> <installations> <hudson.tasks.Maven_-MavenInstallation> <name>maven</name> <home>/usr/share/maven</home> <properties/> </hudson.tasks.Maven_-MavenInstallation> </installations> </hudson.tasks.Maven_-DescriptorImpl>" >> /var/jenkins_home/hudson.tasks.Maven.xml ; chown jenkins:jenkins /var/jenkins_home/hudson.tasks.Maven.xml

# Set up git user 'jenkins'
RUN git config --global user.email "jenkins@jenkins.org"
RUN git config --global user.name "jenkins"

ADD conf-and-run-jenkins.sh /home/jenkins/conf-and-run-jenkins.sh
RUN chmod +x /home/jenkins/conf-and-run-jenkins.sh
RUN chown jenkins:jenkins /home/jenkins/conf-and-run-jenkins.sh

USER jenkins

CMD ["/home/jenkins/conf-and-run-jenkins.sh"]