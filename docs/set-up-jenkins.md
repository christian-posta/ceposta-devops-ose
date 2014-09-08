# Setting up Jenkins for the Continuous Delivery Demo
We use docker containers for all of the continuous deliver pieces, so follow the first section on setting up the
Docker container on your host. Docker isn't required if you wish to manually set up an environment somewhere else.

## Set up Docker container
For this container, we're using an image from the scripts in this project. So you'll need to have this project checked
out into a directory from now on referred to $PROJ_ROOT.

To build the Docker image, navigate to the `gerrit-docker` folder:

    cd $PROJ_ROOT/jenkins-docker
    
Then build the image using `gerrit` as the image name:

    docker build -t myjenkins .
    
Now you should have an image of the gerrit installation we're going to use.

Run the container with this command:

    docker run -itdP --name jenkins --link gitlab:gitlab --link nexus:nexus myjenkins
    
Note we link to the `gitlab` and `nexus` containers, so these containers must have been installed first (the correct
order, as illustrated on the root Readme.md of this project is "Gitlab" then "Nexus".

[See the GitLab setup instructions for more](set-up-gitlab.md).
[See the Nexus setup instructions for more](set-up-nexus.md).

Now you can run the following command to see where on the host Gerrit HTTP listener is installed:

    docker port jenkins 8080
    
## Running a build
At this point you should be able to navigate to the Jenkins page (as exposed on the host and the port from above)
and insepct the build jobs. 