FROM jenkins:1.576

MAINTAINER Christian Posta <christian.posta@gmail.com>


# Let's install all of the plugins we'll need
ADD http://updates.jenkins-ci.org/latest/git.hpi /var/jenkins_home/plugins/git.hpi
ADD http://updates.jenkins-ci.org/latest/ssh-credentials.hpi /var/jenkins_home/plugins/ssh-credentials.hpi
ADD http://updates.jenkins-ci.org/latest/git-client.hpi /var/jenkins_home/plugins/git-client.hpi
ADD http://updates.jenkins-ci.org/latest/scm-api.hpi /var/jenkins_home/plugins/scm-api.hpi
ADD http://updates.jenkins-ci.org/latest/ssh-credentials.hpi /var/jenkins_home/plugins/ssh-credentials.hpi
ADD http://updates.jenkins-ci.org/latest/credentials.hpi /var/jenkins_home/plugins/credentials.hpi
ADD http://updates.jenkins-ci.org/latest/conditional-buildstep.hpi /var/jenkins_home/plugins/conditional-buildstep.hpi
ADD http://updates.jenkins-ci.org/latest/parameterized-trigger.hpi /var/jenkins_home/plugins/parameterized-trigger.hpi
ADD http://updates.jenkins-ci.org/latest/promoted-builds.hpi /var/jenkins_home/plugins/promoted-builds.hpi
ADD http://updates.jenkins-ci.org/latest/build-pipeline-plugin.hpi /var/jenkins_home/plugins/build-pipeline-plugin.hpi
ADD http://updates.jenkins-ci.org/latest/managed-scripts.hpi /var/jenkins_home/plugins/managed-scripts.hpi
ADD http://updates.jenkins-ci.org/latest/copyartifact.hpi /var/jenkins_home/plugins/copyartifact.hpi
ADD http://updates.jenkins-ci.org/latest/envinject.hpi /var/jenkins_home/plugins/envinject.hpi