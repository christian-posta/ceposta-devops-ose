# Fuse Dockerfile
This dockerfile can be used to boot up a fuse environment. Note a fuse installation (either base fabric8-karaf or
jboss-fuse-minimal (or medium or full) must be preset in the directory with the Fuse dockerfile!!)

build the image:

    docker build -t fabric8:fuse-6.1-ose .

if using base fabric8-karaf, run like this (after building the image and name it fabric81.0:latest) to start
fuse when the container is started:


Use something like this fabric8 distro as the fuse version:
http://repository.jboss.org/nexus/content/groups/ea/io/fabric8/fabric8-karaf/1.0.0.redhat-396/fabric8-karaf-1.0.0.redhat-396.zip

    docker run -itdP  --name fuse-qa1 --privileged fabric8:fuse-6.1-ose sudo -u fuse  /opt/rh/fabric8-karaf-1.0.0.redhat-396/bin/fusefabric
    
Otherwise, if this is going to be a container that hosts a fuse ensemble node, don't need to start fuse:
    
    docker run -itdP  --name fuse-qa1 --privileged fabric81.0:latest 
    
Note we run as --privileged to be able to SSH into the container (so fuse can install containers)
    
Can login directly to the fuse shell:

    sshpass -p admin ssh -p 49251 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no admin@localhost
    
Note that requires sshpass (sudo yum -y install sshpass). Otherwise you can enter the password at the CLI.

Create the fabric:

    fabric:create --clean --wait-for-provisioning --zookeeper-password christian
    
or run the whole thing in one line:

    sshpass -p admin ssh -p 49251 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no admin@localhost fabric:create --clean --wait-for-provisioning --zookeeper-password christian
    
Navigate to the correct port (on the host) for fabric8's 8181

Now add the `openshift` profile to fuse:

    sshpass -p admin ssh -p 49251 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no admin@localhost fabric:container-add-profile root openshift

Now try to create a container on OSE through the Fuse registry (which is not deployed on OSE):

    sshpass -p admin ssh -p 49251 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no admin@localhost