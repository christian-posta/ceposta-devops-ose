#!/bin/bash

set -e

# Input Checking

if [ "$#" -ne 3 ]; then
    echo "Invalid Number of Input Parameters"
	exit 1
fi

SOURCE_APP_NAME=$1
MAJOR_VERSION=$2
BUILD_NUMBER=$3



# Cleanse App and Branch names per OpenShift spec
APP_NAME=$(echo ${SOURCE_APP_NAME} | tr -d -c ".[:alnum:]")

# Initialize Variables
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HEADER_ACCEPT="Accept: application/json"
OPENSHIFT_BROKER=https://broker.hosts.pocteam.com
OPENSHIFT_API=/broker/rest/
OPENSHIFT_USER=christian
OPENSHIFT_PASSWORD=christian
# ceposta, dev, qa, prod
OPENSHIFT_DOMAIN=dev
OPENSHIFT_CARTRIDGE_FUSE=fusesource-fuse-1.0.0
OPENSHIFT_GIT_URL=
OPENSHIFT_APP_URL=

# set the app name to include the build versions so we can identify the env
OPENSHIFT_APP_NAME=${APP_NAME}${MAJOR_VERSION}${BUILD_NUMBER}

echo "app name: $OPENSHIFT_APP_NAME"


# Configure SSH
export GIT_SSH=${DIR}/ssh_wrapper.sh


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
declare -a CHECK_APP_EXISTS_RESULT=$(python check_app_exists.py ${OPENSHIFT_BROKER} ${OPENSHIFT_API} ${OPENSHIFT_DOMAIN} ${OPENSHIFT_USER} "${OPENSHIFT_PASSWORD}" "${OPENSHIFT_APP_NAME}" ${OPENSHIFT_CARTRIDGE_FUSE}
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
# RESULT[2] = Git URL of Application
#
# Error Occurred
# RESULT[0] = Status Code 1
# RESULT[1] = Error Message
declare -a APP_CREATE_RESULT=$(python - ${OPENSHIFT_BROKER} ${OPENSHIFT_API} ${OPENSHIFT_DOMAIN} ${OPENSHIFT_USER} "${OPENSHIFT_PASSWORD}" "${OPENSHIFT_APP_NAME}" ${OPENSHIFT_CARTRIDGE_FUSE} <<EOF

import sys, urllib, urllib2, json;

def encodeUserData(username,passwd):
	return "Basic %s" % (("%s:%s" % (username,passwd)).encode('base64').rstrip())

try:
	dict = (("name",sys.argv[6]),("cartridges[][name]",sys.argv[7]))
	dict_encode = urllib.urlencode(dict)
	url = "{0}{1}domain/{2}/applications".format(sys.argv[1],sys.argv[2],sys.argv[3])
	req = urllib2.Request(url)
	req.add_header('Accept','application/json')
	req.add_header('Authorization',encodeUserData(sys.argv[4],sys.argv[5]))
	res = urllib2.urlopen(req, dict_encode)
	result = json.loads(res.read())
	print '("{0}" "{1}" "{2}")'.format("0", result["data"]["app_url"], result["data"]["git_url"])
except urllib2.URLError, e: 
	result = json.loads(e.read())
	print '("{0}" "{1}")'.format("1", result["messages"][0]["text"])
except:
	print ("1")
EOF
)


CREATE_STATUS=${APP_CREATE_RESULT[0]}


if [ "${CREATE_STATUS}" != "0" ]
then
	echo "Application Failed to be Created"
	echo "Error: ${APP_CREATE_RESULT[1]}"
	exit 1
fi

OPENSHIFT_APP_URL=${APP_CREATE_RESULT[1]}
OPENSHIFT_GIT_URL=${APP_CREATE_RESULT[2]}

fi

rm -rf ${OPENSHIFT_APP_NAME}

echo "Cloning Upstream Repository..."
#git clone ${UPSTREAM_GIT} -b ${SOURCE_GIT_BRANCH} ${OPENSHIFT_APP_NAME}

pushd ${OPENSHIFT_APP_NAME} >/dev/null

git remote add openshift ${OPENSHIFT_GIT_URL}

echo "Pushing Repository to OpenShift Application"
#git push -f openshift ${SOURCE_GIT_BRANCH}:master

popd >/dev/null

echo "Writing Variables to Properties File"

echo OPENSHIFT_APP_URL=${OPENSHIFT_APP_URL} > openshift_vars_build${BUILD_NUMBER}
echo OPENSHIFT_GIT_URL=${OPENSHIFT_GIT_URL} >> openshift_vars_build${BUILD_NUMBER}
echo OPENSHIFT_APP_NAME=${OPENSHIFT_APP_NAME} >> openshift_vars_build${BUILD_NUMBER}







