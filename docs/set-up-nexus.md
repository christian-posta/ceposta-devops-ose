# Setting up Nexus for the Continuous Delivery Demo
We use docker containers for all of the continuous deliver pieces, so follow the first section on setting up the
Docker container on your host. Docker isn't required if you wish to manually set up an environment somewhere else.


## Set up Docker container
You'll need to pull the GitLab docker image that we use for this demo:
 
    docker pull pantinor/centos-nexus:latest


Run the container with this command:

    docker run -itdP --name nexus pantinor/centos-nexus:latest
    
[See the Nexus setup instructions for more](set-up-nexus.md).

Now you can run the following command to see where on the host Gerrit HTTP listener is installed:

    docker port nexus 8081
    
## Navigate and login to nexus
You can go to the port on the host as shown by the docker port command above, just make sure to go to the "/nexus" 
context path.

For example, on my machine that would be:

    http://ceposta-public:49159/nexus
    
You can try logging in with the default un/pw of __admin/admin123__