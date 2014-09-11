#!/bin/sh

set -e

if [ "$#" -ne 2 ]; then
    echo "Invalid Number of Input Parameters.. you need to pass the hostname and port of the gerrit app"
    echo "eg: conf-jenkins-user.sh 127.0.0.1 28001"
	exit 1
fi

GERRIT_HOST="$1"
GERRIT_PORT="$2"
GERRIT_APP_PROJ_TMP="/tmp/All-Projects"

#
# Discover the APP_BASE from the location of this script.
#
if [ -z "$APP_BASE" ] ; then
  ## resolve links - $0 may be a link to apollo's home
  PRG="$0"
  saveddir=`pwd`

  # need this for relative symlinks
  dirname_prg=`dirname "$PRG"`
  cd "$dirname_prg"

  while [ -h "$PRG" ] ; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '.*/.*' > /dev/null; then
      PRG="$link"
    else
      PRG=`dirname "$PRG"`"/$link"
    fi
  done

  APP_BASE=`dirname "$PRG"`
  cd "$saveddir"

  # make it fully qualified
  APP_BASE=`cd "$APP_BASE/.." && pwd`
  export APP_BASE
fi


#
#
# Check if jenkins user exists, if does not, create it
NON_INTERACTIVE_MEMBERS=$(
ssh -p "$GERRIT_PORT" -i "$APP_BASE"/gerrit-docker/ssh-keys/gerrit-admin admin@"$GERRIT_HOST" 'gerrit ls-members "Non-Interactive Users"'
)

if [[ $NON_INTERACTIVE_MEMBERS != *jenkins* ]]
then
  echo "Jenkins user does not exist, creating one..."
  cat "$APP_BASE"/jenkins-docker/ssh-keys/jenkins.pub | ssh -p "$GERRIT_PORT" -i "$APP_BASE"/gerrit-docker/ssh-keys/gerrit-admin admin@"$GERRIT_HOST" gerrit create-account --group "'Non-Interactive Users'" --full-name Jenkins --email jenkins@jenkins.org --ssh-key - jenkins
else
    echo "Jenkins user already exists!! Not creating it.."
fi



#
#
# Update roles and permissions
if [ -d "$GERRIT_APP_PROJ_TMP" ]; then
  if [ -L "GERRIT_APP_PROJ_TMP" ]; then
    # It is a symlink!
    # Symbolic link specific commands go here.
    rm "$GERRIT_APP_PROJ_TMP"
  else
    # It's a directory!
    # Directory command goes here.
    rm -fr "$GERRIT_APP_PROJ_TMP"
  fi
fi

function safegit() {
 ssh-agent bash -c "ssh-add $APP_BASE/gerrit-docker/ssh-keys/gerrit-admin; $@"
}


mkdir -p "$GERRIT_APP_PROJ_TMP"
cd $GERRIT_APP_PROJ_TMP
git init
git config user.name "Administrator"
git config user.email "admin@company.com"
git remote add origin "ssh://admin@"$GERRIT_HOST":"$GERRIT_PORT"/All-Projects"
safegit "git fetch origin refs/meta/config:refs/remotes/origin/meta/config"
git checkout meta/config
cp $APP_BASE/gerrit-docker/git/project-config/project.config $GERRIT_APP_PROJ_TMP/project.config
git commit -a -m 'automatically updating the project access settings'
safegit "git push origin meta/config:meta/config"

