# Setting up Docker on RHEL for the Continuous Delivery Demo


We are going to install the requisite software with Docker. So we need to have Docker.
You’ll want to have docker images on a separate volume. See the notes from here:

## Install prerequisites

On RHEL/Centos, you'll need to install the EPEL repos:

    sudo rpm -ivh http://mirrors.syringanetworks.net/fedora-epel/6/i386/epel-release-6-8.noarch.rpm


## Attaching external volume
You’ll want to attach a separate volume for docker images because they tend to take up a lot of space.

Should do this before running docker for the first time

In OpenStack, find the volume and attach it. Then run these commands:


    # mkfs -t ext3 /dev/vdb
    # mkdir /var/lib/docker
    # mount -t ext3 /dev/vdb /var/lib/docker

## Install docker

You can add your user to the allowed docker group with this (so you don't have to _sudo_ every time)

    usermod -a -G docker <your-user>

On openstack, the default user is `cloud-user` so the command would be:

    usermod -a -G docker cloud-user
    
You may need to log back into your shell session (as I don't know how to get the usermod to kick in without doing..
any suggestions?)
   
Now you can install from the yum repos:

    sudo yum -y install docker-io
    sudo chkconfig docker on
    sudo service docker start

    
## iptables firewall

You can add specific docker ports to your _iptables_ like this: 

    sudo iptables -A INPUT -p tcp --dport 49154 -j ACCEPT -m comment --comment “gerrit code review system”

or specify an entire set of ports that docker uses:

    iptables -A INPUT -p tcp --match multiport --dports 49000:49900 -j ACCEPT -m comment --comment 'docker ports'

## nsenter to login to a container
You should also set up _nsenter_ as described in this blog post so you don't have to worry about an
SSH dameon:

    http://blog.docker.com/2014/06/why-you-dont-need-to-run-sshd-in-docker/