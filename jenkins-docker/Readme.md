# Jenkins Dockerfile

This is the Dockerfile for jenkins. It shows, step-by-step, how to set up the Jenkins installation for this demo.
It also acts as the "source" code for our automation, so you could actually script these steps however you like 
(ansible, bash, python, etc), but at the very least the steps are up to date and accurate. 

This Dockerfile builds on the trusted jenkins build from the docker repo [you can find the official Jenkins Dockerfile
here](https://registry.hub.docker.com/_/jenkins/). We pick a specific tag (1.576) so it doesn't change out from under
us. After inheriting the official build, we add a bunch of plugins [as seen in the Dockerfile](Dockerfile) itself.
These are the plugins we use in the projects.

The next step is to add the specific Jenkins "jobs" into our work space. We do that as well as replace any of the
property place holders. The property placeholders of interest are listed in the [conf-and-run-jenkins.sh](conf-and-run-jenkins.sh) script and can be summarized here:

    __GITLAB_IP__ this is the location of the Gitlab server, the assumtion is port 80
    __NEXUS_IP__ this is the location of the sonatype nexus server
    __NEXUS_PORT__ this is the port of the nexus server
    
Keep in mind these are all scripted out of the box to look at environment variables. Also, by default for the demo,
the docker containers are all linked and the env variables are all set automatically. If you run this outside the 
docker environment, you can just set the environment variables yourself. See the script above for the env variable
names.

You should see [the guide for setting up the Jenkins docker container for this demo](../docs/set-up-jenkins.md). 