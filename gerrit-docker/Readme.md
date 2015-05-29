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