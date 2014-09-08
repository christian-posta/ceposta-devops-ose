# Set up the demo
The following are the technology pieces involved with the Continuous Delivery demo. 

* Gitlab 
* Gerrit Code Review system
* Sonatype Nexus
* Jenkins

    NOTE!! when installing these with Docker, as the demo is built on, make sure the respective pieces
    are installed in the order this guide lists them.
    
As mentioned in the opening page, this demo relies on [Docker](http://docker.com) to package up the individual
pieces, so if you need help installing docker specifically for this demo (on RHEL or CentOS), see [this guide for setting up our Docker environment on RHEL 6.5 for this demo](docs/set-up-docker.md).

Each section is listed in the order it's to be installed. Once you have docker installed, follow each section's guide.
There is a few manual steps you'll need to do, so if anyone wants to contribute any automation to it, please feel free!

## Gitlab
GitHub is great for hosting code, reviewing branches, reviewing commits, tracking issues, etc. But we prefer an
OpenSource solution for this demonstration so that anyone can get started. [GitLab][gitlab] is an excellent alternative
to GitHub for internal/private hosting.

We use Gitlab to be able to view our code through a web browser, track changes, branches, etc. You could also 
use GitLab for pull requests and use the GitHub style pull-request model if the Gerrit model isn't what you're looking
for.

For the Docker environment we have for this demo, you'll want to start the Gitlab container first, since 
all of the other containers link to it.

See [this guide for setting up Gitlab as a Docker container for this demo](docs/set-up-gitlab.md)

## Gerrit
We use [Gerrit][gerrit]https://code.google.com/p/gerrit/ to demonstrate a key piece of the Continuous Delivery/Devops
work flow. Allowing teams to contribute to a large complex integration project takes a little more care, especially 
when getting new people on your team, or accepting junior developers to submit code. The traditional GitHub pull-request
model works great for some open source projects, but for those teams wishing to bring an open-source feel to their
teams along with tracking changesets, encouraging cross-developer interaction and knowledge sharing as well as 
conforming to a team style/convention, then Gerrit is the tool to help you do that. 

With Gerrit, you can code review your changesets, track the feedback loop that usually happens when reviewing code,
and merge with master when the code is ready. This also keeps broken builds on your master/CI branch to a minimum.

See [this guide for setting up Gerrit as a Docker container for this demo](docs/set-up-gerrit.md)

## Nexus
We use [Sonatype Nexus][nexus]to model our enterprise artifact repository. In here we can store our build artifacts
(for example, not just jars and wars, but our JBoss Fuse/Fabric8 profiles) and access them across environments. Nexus
plays a central role in our [continuous delivery][cd] pipline. 

See [this guide for setting up Nexus as a Docker container for this demo](docs/set-up-nexus.md)

## Jenkins
Jenkins provides the heavy lifting for our continuous integration and continuous delivery pipline. Just like the
other components, this piece is delivered as an out-of-the box Jenkins already configured to use the other containers
(Gitlab, Nexus, etc) and it also has the projects needed for the CD demo already configured. You'll have to make sure
the other external pieces (OpenShift, Gitlab/Nexus) are set up correctly, but all of the projects are all ready to 
go.

You may wish to set up additional features (like email proxy, or user accounts), so for a complete guide,
see [the guide for setting up Jenkins as a Docker contianer for this demo](docs/set-up-jenkins.md)

### Jenkins plugins
Here are a list of Jenkins plugins we use for our Continuous Delivery setup. They are listed here for completeness.
You don't have to install this separately as it's all automated.

* Conditional Build plugin
* Paramaterized Build plugin
* Promoted Build plugin
* Build pipeline
* Copy artifacts
* EnvInject plugin
* ConfigFile plugin
* Git
* Maven

You can see the full, up to date list, [directly on the Dockerfile for the Jenkins container](jenkins-docker/Dockerfile)

## JBoss Fuse
For this demo, we're using [JBoss Fuse 6.1][fuse]. JBoss Fuse proivdes the integration platform onto which we deploy
our integrations. For the demo, we're using a simple REST based integration project that can be deployed onto 
multiple containers as well as enlist itself into the API registry. From there you can choose to discover and bind to
one of the endpoints at runtime or loadbalance against the endpoint collection.

You couuld even bring up an HTTP gateway to do the auto discovery.

For this demo, however, we're going to be deploying our Fuse projects onto [OpenShift][openshift], a 
PaaS supporting multiple technology stacks, including Fuse. 

Check out the [architecture diagram and setting up Fuse for this demo](docs/set-up-fuse.md)
