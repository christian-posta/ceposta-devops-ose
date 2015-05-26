# Gerrit Dockerfile

This is the Dockerfile for setting up Gerrit in our demo. Please have a look at the details, but the
key pieces to keep in mind:

* We disable authentication for this demo. We use DEVELOPMENT_BECOME_ANY_ACCOUNT to allow us to become any account for
demo purposes. Gerrit uses SSO by default. To see the security options, [see the gerrit documentation](https://gerrit-documentation.storage.googleapis.com/Documentation/2.8/config-gerrit.html) 

* We have set up replication to happen automatically to the Gitlab repo. This coordination is done in the
[replication.config](replication.config) file. You'll notice there are property placeholders in there. These get
replaced when linking the docker containers and starting up. If you choose to run outside of docker, you'll need
to replace the properties yourself:

    __GITLAB_USER__ the user account on gitlab that will host the replicated repositories
    __GITLAB_PASSWORD__ the password for the account
    __GITLAB_IP__ the location of the gitlab servier (IP or dns if dns is resolvable)
    __GITLAB_PROJ_ROOT__ the root location of where the projects will be stored on gitlab (usually the username)
    
    
Keep in mind these are all scripted out of the box to look at environment variables. Also, by default for the demo,
the docker containers are all linked and the env variables are all set automatically. If you run this outside the 
docker environment, you can just set the environment variables yourself. See the script above for the env variable
names.

You should see [the guide for setting up the gerrit docker container for this demo](../docs/set-up-gerrit.md). 

TODO - Explain how to build the image, deploy it and install the kube application

# Build Docker image & deploy it to docker

```
export DOCKER_HOST=tcp://172.28.128.4:2375
mvn clean install docker:build -Ddocker.host=$DOCKER_HOST
```

# Push the docker image to the openshift-registry

```
export DOCKER_REGISTRY=$(osc get -o yaml service docker-registry | grep portalIP | awk '{ print $2 }'):5000
osc project default
osc login -u admin -p admin https://172.28.128.4:8443
mvn docker:push -Ddocker.host=$DOCKER_HOST -Ddocker.username=admin -Ddocker.password=admin -Ddocker.registry=$DOCKER_REGISTRY
```

# Create the application (service, replicationContoller, pod)

```
export KUBERNETES_NAMESPACE=default
export KUBERNETES_MASTER=https://172.28.128.4:8443
export KUBERNETES_DOMAIN=vagrant.local
export KUBERNETES_TRUST_CERT="true"
osc project default
osc login -u admin -p admin https://172.28.128.4:8443
mvn clean fabric8:json fabric8:apply

OR 

mvn clean fabric8:json fabric8:apply -Dfabric8.apply.recreate=true
```

# Generate the json file and next apply it

```
mvn clean fabric8:json compile
mvn fabric8:apply -Dfabric8.apply.recreate=true

osc create -f target/classes/kubernetes.json
```

# To create the routes
```
mvn fabric8:create-routes
```

# Create thedocker container
``` 
docker run -dP --name gerrit -p 0.0.0.0:8080:8080 -p 127.0.0.1:29418:29418 -e GITLAB_USER=root -e GITLAB_PASSWORD=redhat01 -e GITLAB_PROJ_ROOT=root -e AUTH_TYPE=OpenID fabric8/gerrit:1.0
```
# Bash to the container
```
docker exec -it gerrit bash
```
# To cleanup the project, reinstall the base app and the openshift registry, run this command within the VM Machine 
```
osc delete se,rc,dc,bc,oauthclient,pods,route --all

osc delete all --all

osc delete rc gerrit-controller
osc delete se gerrit-service
osc delete pods -l component=gerrit

osc process -v DOMAIN='vagrant.local' -f http://central.maven.org/maven2/io/fabric8/apps/base/2.1.1/base-2.1.1-kubernetes.json | osc create -f -
sudo osadm registry --create --credentials=/var/lib/openshift/openshift.local.config/master/openshift-registry.kubeconfig
```  


