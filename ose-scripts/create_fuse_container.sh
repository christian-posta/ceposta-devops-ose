#!/bin/sh


if [ "$#" -ne 4 ]; then
    echo "Invalid Number of Input Parameters"
    echo "args: FuseHost AdminPassword OSEBrokerUrl BuildNumber"
	exit 1
fi

#FUSE_HOST=fuse101-dev.ose.pocteam.com
#FUSE_ADMIN_PASSWORD=EPAaj4k44p8v
#OPENSHIFT_BROKER=broker.hosts.pocteam.com
#BUILD_NUMBER=1.0.3
#PROFILE_NAME=my-rest

FUSE_HOST=$1
FUSE_ADMIN_PASSWORD=$1
OPENSHIFT_BROKER=$3
BUILD_NUMBER=$4
PROFILE_NAME=my-rest
CONTAINER_NAME=$(echo restcontainer${BUILD_NUMBER} | tr -d -c "[:alnum:]")

echo "$CONTAINER_NAME"


alias ssh2fabric="sshpass -p $FUSE_ADMIN_PASSWORD ssh -p 53562 -o ServerAliveCountMax=100 -o ConnectionAttempts=180 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o LogLevel=ERROR admin@$FUSE_HOST"

#
# create a container with our profile
ssh2fabric "fabric:container-create-openshift --login christian --password christian --gear-size xpaas --server-url $OPENSHIFT_BROKER --profile $PROFILE_NAME $CONTAINER_NAME"