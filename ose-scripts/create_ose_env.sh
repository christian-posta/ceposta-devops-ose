#!/bin/bash

set -e

# Input Checking

if [ "$#" -ne 4 ]; then
    echo "Invalid Number of Input Parameters"
    echo "args: AppName VersionNumber OSEBrokerUrl OSEDomain"
	exit 1
fi

SOURCE_APP_NAME=$1
VERSION_NUMBER=$2
OPENSHIFT_BROKER=$3
OPENSHIFT_DOMAIN=$4



# Cleanse App and Branch names per OpenShift spec
APP_NAME=$(echo ${SOURCE_APP_NAME} | tr -d -c "[:alnum:]")

# Initialize Variables
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HEADER_ACCEPT="Accept: application/json"
OPENSHIFT_API=/broker/rest/
OPENSHIFT_USER=christian
OPENSHIFT_PASSWORD=christian
# ceposta, dev, qa, prod
OPENSHIFT_DOMAIN=dev
OPENSHIFT_CARTRIDGE_FUSE=fuse-1.0.0


# set the app name to include the build versions so we can identify the env
OPENSHIFT_APP_NAME=$(echo ${APP_NAME}${VERSION_NUMBER} |  tr -d -c "[:alnum:]")

echo "app name: $OPENSHIFT_APP_NAME"


function cleanup() {
	rm -rf ${OPENSHIFT_APP_NAME}
}

trap cleanup 0



# Check to see if application already exists and returns an array of values. Depending on the response, the following is returned
#
# Application Does Not Exist
# RESULT[0] = Status Code 0
#
# Application Does Exist
# RESULT[0] = Status Code 2
# RESULT[1] = Application URL 
# RESULT[2] = Git URL of Application
#
# Error Occurred
# RESULT[0] = Status Code 1
# RESULT[1] = Error Message
echo "checking whether this app already exists in this environment"
declare -a CHECK_APP_EXISTS_RESULT=$(python ${DIR}/check_app_exists.py ${OPENSHIFT_BROKER} ${OPENSHIFT_API} ${OPENSHIFT_DOMAIN} ${OPENSHIFT_USER} "${OPENSHIFT_PASSWORD}" "${OPENSHIFT_APP_NAME}" ${OPENSHIFT_CARTRIDGE_FUSE}
)

if [ "${CHECK_APP_EXISTS_RESULT[0]}" == "1" ]
then
	echo "An Error Occurred ${CHECK_APP_EXISTS_RESULT[1]}"
	exit 1
elif [ "${CHECK_APP_EXISTS_RESULT[0]}" == "2" ]
then 
	echo "Application Already Exists. Skipping Application Creation"

	# Set App URL and Git URL
	OPENSHIFT_APP_URL=${CHECK_APP_EXISTS_RESULT[1]}
	OPENSHIFT_GIT_URL=${CHECK_APP_EXISTS_RESULT[2]}	
elif [ "${CHECK_APP_EXISTS_RESULT[0]}" == "0" ]
then

echo
echo "Creating Application"
echo


# Attempt to create an application and return an array of values. Depending on the response, the following is returned
#
# Application Created Successfully
# RESULT[0] = Status Code 0
# RESULT[1] = Application URL
# RESULT[2] = SSH url
# RESULT[3] = Console User Name
# RESULT[4] = Console Password
# RESULT[5] = ZK URL
# RESULT[6] = ZK Password
#
# Error Occurred
# RESULT[0] = Status Code 1
# RESULT[1] = Error Message
declare -a APP_CREATE_RESULT=$(python ${DIR}/create_new_app.py ${OPENSHIFT_BROKER} ${OPENSHIFT_API} ${OPENSHIFT_DOMAIN} ${OPENSHIFT_USER} "${OPENSHIFT_PASSWORD}" "${OPENSHIFT_APP_NAME}" ${OPENSHIFT_CARTRIDGE_FUSE}
)


CREATE_STATUS=${APP_CREATE_RESULT[0]}


if [ "${CREATE_STATUS}" != "0" ]
then
	echo "Application Failed to be Created"
	echo "Error: ${APP_CREATE_RESULT[1]}"
	exit 1
else
    echo "Created application ${APP_CREATE_RESULT[1]} successfully"
fi


FUSE_ROOT_URL=${APP_CREATE_RESULT[1]}
FUSE_GEAR_SSH=${APP_CREATE_RESULT[2]}
FUSE_CONSOLE_USER=${APP_CREATE_RESULT[3]}
FUSE_CONSOLE_PASSWORD=${APP_CREATE_RESULT[4]}
FUSE_ZK_URL=${APP_CREATE_RESULT[5]}
FUSE_ZK_PASSWORD=${APP_CREATE_RESULT[6]}
FUSE_DOMAIN_NAME=$(echo ${FUSE_ZK_URL} | cut -d ':' -f 1)

echo "Writing Variables to Properties File"


rm -fr ${DIR}/vars
mkdir -p ${DIR}/vars

echo FUSE_ROOT_URL=${FUSE_ROOT_URL} > ${DIR}/vars/openshift_vars_build-${VERSION_NUMBER}
echo FUSE_GEAR_SSH=${FUSE_GEAR_SSH} >> ${DIR}/vars/openshift_vars_build-${VERSION_NUMBER}
echo FUSE_CONSOLE_USER=${FUSE_CONSOLE_USER} >> ${DIR}/vars/openshift_vars_build-${VERSION_NUMBER}
echo FUSE_CONSOLE_PASSWORD=${FUSE_CONSOLE_PASSWORD} >> ${DIR}/vars/openshift_vars_build-${VERSION_NUMBER}
echo FUSE_ZK_URL=${FUSE_ZK_URL} >> ${DIR}/vars/openshift_vars_build-${VERSION_NUMBER}
echo FUSE_ZK_PASSWORD=${FUSE_ZK_PASSWORD} >> ${DIR}/vars/openshift_vars_build-${VERSION_NUMBER}
echo FUSE_DOMAIN_NAME=${FUSE_DOMAIN_NAME} >> ${DIR}/vars/openshift_vars_build-${VERSION_NUMBER}

echo "try get fuse ssh url"

#SSH_URL_JSON=$(curl --insecure -X POST --user admin:Jd5bgvF1hXiK --data '{"arguments":["${OPENSHIFT_APP_NAME}",["sshUrl"]],"mbean":"io.fabric8:type=Fabric","operation":"getContainer(java.lang.String,java.util.List)","type":"exec"}'  '${FUSE_ROOT_URL}jolokia/exec')

declare -a SSH_URL_RESULT=$(
    python ${DIR}/get_container_ssh.py $FUSE_ROOT_URL $OPENSHIFT_APP_NAME
)

if [ "${SSH_URL_RESULT[0]}" != 0 ]
then
    echo "Could not find the container's SSH URL... we should kill the env create and try again"
    echo ${SSH_URL_RESULT[1]}
    exit 1
else
    echo "Found the Fuse SSH Url to use: ${SSH_URL_RESULT[1]}"
fi

FUSE_CONTAINER_SSH=${SSH_URL_RESULT[1]}
echo FUSE_CONTAINER_SSH=${FUSE_CONTAINER_SSH} >> ${DIR}/vars/openshift_vars_build-${VERSION_NUMBER}

# end the entire large if
else
    echo "There was major error"
    echo "check result: ${CHECK_APP_EXISTS_RESULT[1]}"
    echo "create result: ${APP_CREATE_RESULT[1]}"
fi



