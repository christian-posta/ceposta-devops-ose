#!/bin/bash

set -e

# Input Checking

if [ "$#" -ne 3 ]; then
    echo "Invalid Number of Input Parameters"
	exit 1
fi

UPSTREAM_GIT=$1
SOURCE_APP_NAME=$2
SOURCE_GIT_BRANCH=$3



# Cleanse App and Branch names per OpenShift spec
APP_NAME=$(echo ${SOURCE_APP_NAME} | tr -d -c ".[:alnum:]")
GIT_BRANCH=$(echo ${SOURCE_GIT_BRANCH} | tr -d -c ".[:alnum:]")

# Initialize Variables
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HEADER_ACCEPT="Accept: application/json"
OPENSHIFT_BROKER=https://broker.hosts.osecloud.com
OPENSHIFT_API=/broker/rest/
OPENSHIFT_USER=christian
OPENSHIFT_PASSWORD=christian
# ceposta, dev, qa, prod
OPENSHIFT_DOMAIN=dev
OPENSHIFT_CARTRIDGE_FUSE=fusesource-fuse-1.0.0
OPENSHIFT_CARTRIDGE_JENKINS_CLIENT=jenkins-client-1
OPENSHIFT_GIT_URL=
OPENSHIFT_APP_URL=
OPENSHIFT_APP_NAME=${APP_NAME}${GIT_BRANCH}


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
declare -a CHECK_APP_EXISTS_RESULT=$(python - ${OPENSHIFT_BROKER} ${OPENSHIFT_API} ${OPENSHIFT_DOMAIN} ${OPENSHIFT_USER} "${OPENSHIFT_PASSWORD}" "${OPENSHIFT_APP_NAME}" ${OPENSHIFT_CARTRIDGE_FUSE} ${OPENSHIFT_CARTRIDGE_JENKINS_CLIENT} <<EOF

import sys, urllib, urllib2, json;

def encodeUserData(username,passwd):
	return "Basic %s" % (("%s:%s" % (username,passwd)).encode('base64').rstrip())

try:
	#dict = (("name",sys.argv[6]),("cartridges[][name]",sys.argv[7]),("cartridges[][name]",sys.argv[8]))
	#dict_encode = urllib.urlencode(dict)
	url = "{0}{1}domain/{2}/application/{3}?nolinks=true".format(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[6])
	req = urllib2.Request(url)
	req.add_header('Accept','application/json')
	req.add_header('Authorization',encodeUserData(sys.argv[4],sys.argv[5]))
	res = urllib2.urlopen(req)
	result = json.loads(res.read())
	if "ok" == result["status"]:
		print '("{0}" "{1}" "{2}")'.format("2", result["data"]["app_url"], result["data"]["git_url"])
	else:
		print "1"
except urllib2.URLError, e: 
	result = json.loads(e.read())
	if "not_found" == result["status"]:
		print ("0")
	else:
		print '("{0}" "{1}")'.format("1", result["messages"][0]["text"])
except:
	print ("1")
EOF
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

fi