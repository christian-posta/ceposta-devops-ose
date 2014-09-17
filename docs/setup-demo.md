# Set up the demo
    
As mentioned in the opening page, this demo relies on [Docker](http://docker.com) to package up the individual
pieces, so if you need help installing docker specifically for this demo (on RHEL or CentOS), see [this guide for setting up our Docker environment on RHEL 6.5 for this demo](set-up-docker.md).

The following are the technology pieces involved with the Continuous Delivery demo. 

* Gitlab 
* Gerrit Code Review system
* Sonatype Nexus
* Jenkins




## Automated setup w/ Docker
The [bootstrap](../bootstrap) directory contains two files you can use to automate setting up the docker images
and docker containers.

    $PROJ_ROOT/bootstrap/build_docker_images.sh
    
This script will automate building all of the docker images required for this project. It will either pull them
from their respective repos or build them.


    $PROJ_ROOT/bootstrap/run-docker.sh
    
This script will startup all the necessary containers in the right order. It will also print out the location
of each container as seen from the docker host. Example:

    [cloud-user@ceposta-public bootstrap]$ ./run-docker.sh 
    Creating the docker images using gitlab user root and project root 'root'
    a5e66d7167c893fcf9bc4012aedb2f4fda3ff0ca1279191d591605ca295835ba
    d6ddc806bf09022627f2c013108367cff451202b8bc06bff60af13e784f3c3a5
    5ed7bbf78e01f782e14ab807581d09c13c002638bcce26162c5cd40433cb0158
    507da754a94f9d28f3309dae81ce92dbcc1c083fafeae6ee2a6bacebd6f02a29
    Docker host name is ceposta-public
    Gerrit:  http://ceposta-public:49176/
    Gitlab:  http://ceposta-public:49173/
    Jenkins: http://ceposta-public:49178/
    Nexus:   http://ceposta-public:49175/nexus

    
This is the quickest way to get up and running. Even after you set up the docker environment, there are going to be a
couple manual steps (like importing the project, setting up usernames, etc). See each respective section for how
to do that. 

I know, I know there are quite a few crufty manual steps, but these are just to set up the demo. If you have a suggestion
for how to automate, please let me know with a pull request!

## Setting things up manually


Each section is listed in the order it's to be installed. Once you have docker installed, follow each section's guide.
There are a few manual steps you'll need to do, so if anyone wants to contribute any automation to it, please feel free!

__NOTE__!! when installing these with Docker, as the demo is built on, make sure the respective pieces
are installed in the order this guide lists them. Or you can use the _bootstrap_ scripts in the [bootstrap](../bootstrap)
directory.

## Gitlab
For the Docker environment we have for this demo, you'll want to start the Gitlab container first, since 
all of the other containers link to it.

See [this guide for setting up Gitlab as a Docker container and any manual set up for this demo](set-up-gitlab.md)

## Gerrit
See [this guide for setting up Gerrit as a Docker container for this demo as well as any manual set up](set-up-gerrit.md)

## Nexus

See [this guide for setting up Nexus as a Docker container and any manual steps for this demo](set-up-nexus.md)

## Jenkins

You may wish to set up additional features (like email proxy, or user accounts), so for a complete guide,
see [the guide for setting up Jenkins as a Docker contianer for this demo](set-up-jenkins.md)


## JBoss Fuse
For this demo, we're using [JBoss Fuse 6.1][fuse]. JBoss Fuse proivdes the integration platform onto which we deploy
our integrations. For the demo, we're using a simple REST based integration project that can be deployed onto 
multiple containers as well as enlist itself into the API registry. From there you can choose to discover and bind to
one of the endpoints at runtime or loadbalance against the endpoint collection.

You cuuld even bring up an HTTP gateway to do the auto discovery.

For this demo, however, we're going to be deploying our Fuse projects onto [OpenShift][openshift], a 
PaaS supporting multiple technology stacks, including Fuse. 

Check out the [architecture diagram and setting up Fuse for this demo](set-up-fuse.md)



[docker]: https://www.docker.com
[fuse]: http://www.jboss.org/products/fuse/overview/
[microservices]: http://microservices.io
[openshift]: https://www.openshift.com
[dockerfile]: https://docs.docker.com/reference/builder/
[vbox]: https://www.virtualbox.org
[gerrit]: https://code.google.com/p/gerrit/
[gitlab]: https://about.gitlab.com
[nexus]: http://www.sonatype.org/nexus/
[cd]: http://en.wikipedia.org/wiki/Continuous_delivery
