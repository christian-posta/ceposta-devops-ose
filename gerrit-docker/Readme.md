# Gerrit Dockerfile

This is the Dockerfile for setting up Gerrit in our demo. Please have a look at the details, but the
key pieces to keep in mind:

* We disable authentication for this demo. We use DEVELOPMENT_BECOME_ANY_ACCOUNT to allow us to become any account for
demo purposes. Gerrit uses SSO by default. To see the security options, [see the gerrit documentation](https://gerrit-documentation.storage.googleapis.com/Documentation/2.8/config-gerrit.html) 

* We have set up replication to happen automatically to the Gitlab repo. This coordination is done in the
[replication.config](replication.config) file. You'll notice there are property placeholders in there. These get
replaced when linking the docker containers and starting up. If you choose to run outside of docker, you'll need
to replace the properties yourself:

    __GIT_SERVER_USER__ the user account on git sever (gitlab, gogs, ...) that will host the replicated repositories
    __GIT_SERVER_PASSWORD__ the password for the account
    __GIT_SERVER_IP__ the location of the git servier (IP or dns if dns is resolvable)
    __GIT_SERVER_PROJ_ROOT__ the root location of where the projects will be stored on the git server (usually the username)
    
    
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

OR for external build with the docker io registry

mvn clean install docker:build
```

# Push the docker image to the openshift-registry

```
export DOCKER_REGISTRY=$(osc get -o yaml service docker-registry | grep portalIP | awk '{ print $2 }'):5000
osc project default
osc login -u admin -p admin https://172.28.128.4:8443
mvn docker:push -Ddocker.host=$DOCKER_HOST -Ddocker.username=admin -Ddocker.password=admin -Ddocker.registry=$DOCKER_REGISTRY
```

# Push the docker image to the official registry
```
mvn docker:push -Ddocker.username='cmoulliard' -Ddocker.password='xxxxx' -Ddocker.registry="registry.hub.docker.com'
```

# Build and push the docker image to the official registry
```
mvn clean docker:build docker:push -Ddocker.username='cmoulliard' -Ddocker.password='B1kers99!' -Ddocker.registry="registry.hub.docker.com"
```



# Create the application (service, replicationContoller, pod)

```
export KUBERNETES_NAMESPACE=default
export KUBERNETES_MASTER=https://172.28.128.4:8443
export KUBERNETES_DOMAIN=vagrant.local
export KUBERNETES_TRUST_CERT="true"
osc project default
osc login -u admin -p admin https://172.28.128.4:8443
mvn clean fabric8:json compile
mvn fabric8:apply -Dfabric8.apply.recreate=true
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

# Create a docker gerrit container
``` 
docker run -dP -p 0.0.0.0:8080:8080 -p 127.0.0.1:29418:29418 -e GIT_SERVER_USER=root -e GIT_SERVER_PASSWORD=redhat01 -e GIT_SERVER_PROJ_ROOT=root -e AUTH_TYPE=OpenID -v /home/gerrit/db:/home/gerrit/gerrit/db --name my-gerrit cmoulliard/gerrit:1.0
```
# Bash to the container
```
docker exec -it gerrit bash
```
# To cleanup the project, reinstall the base app and the openshift registry, run this command within the VM Machine 
```
osc delete rc gerrit-controller
osc delete se gerrit-http-service
osc delete se gerrit-ssh-service
osc delete route gerrit-http-service-route
osc delete route gerrit-ssh-service-route
osc delete pod -l component=gerrit

Check if we still have gerrit stuffs

osc get all | grep gerrit

We don't have to recreate the registry or router in this case

OR

osc delete all --all
osc delete oauthclients fabric8

osc process -v DOMAIN='vagrant.local' -f http://central.maven.org/maven2/io/fabric8/apps/base/2.1.1/base-2.1.1-kubernetes.json | osc create -f -

Commands to be executed within the VM machine

sudo osadm registry --create --credentials=/var/lib/openshift/openshift.local.config/master/openshift-registry.kubeconfig
sudo osadm router --create --credentials=/var/lib/openshift/openshift.local.config/master/openshift-router.kubeconfig
```
  
# Generate SSH keys on MacosX
  
https://help.github.com/articles/generating-ssh-keys/#step-2-generate-a-new-ssh-key
  
```
ssh-keygen -t rsa -b 4096 -C "secret@fabric8.io"
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/chmoulli/.ssh/id_rsa): /Users/chmoulli/.ssh/secret_fabric8_rsa
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /Users/chmoulli/.ssh/secret_fabric8_rsa.
Your public key has been saved in /Users/chmoulli/.ssh/secret_fabric8_rsa.pub.
The key fingerprint is:
eb:1b:2b:99:8d:9d:32:0b:fc:1f:ae:04:c5:38:a5:3e secret@fabric8.io
The key's randomart image is:
+--[ RSA 4096]----+
|      .          |
|     =           |
|    + o          |
|   . o           |
|    E   S        |
|   . o   .       |
|    o .*+.       |
|     +Bo++       |
|      +B*.       |
+-----------------+
```

# Transform in Base64 the keys file (pub, private)

```
openssl base64 -in ssh-keys/secret_fabric8_rsa -out ssh-keys/secret_fabric8_rsa_base64
openssl base64 -in ssh-keys/secret_fabric8_rsa.pub -out ssh-keys/secret_fabric8_rsa_pub_base64

```

# generate the json file to add the ssh keys to openshift

```
./ssh-keys-base64.sh
```

# Temp - Delete gogs

osc delete rc gogs-controller
osc delete se gogs
osc delete route gogs-route
osc delete pod -l component=gogs

osc get all | grep gogs

# Test to mount volume with docker directly

docker run -v /home/gerrit/data:/home/gerrit/gerrit/data -v /home/gerrit/etc:/home/gerrit/gerrit/etc -v /home/gerrit/db:/home/gerrit/gerrit/db --name my-gerrit -d cmoulliard/gerrit:1.0

# To clean images
   
docker rmi -f $(docker images --no-trunc=true --filter dangling=true --quiet)

# Kill all running containers
docker kill $(docker ps -q)

# Delete all stopped containers (including data-only containers)
docker rm $(docker ps -a -q)

# Delete all ‘untagged/dangling’ (<none>) images
docker rmi $(docker images -q -f dangling=true)

# Delete ALL images
docker rmi $(docker images -q)
   


