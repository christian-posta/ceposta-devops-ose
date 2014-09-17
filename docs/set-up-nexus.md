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

## Gotchas
For our Jenkins server to build projects correctly, we'll need to be able to reach repository.jboss.org, specifically
through this url:

    curl -L https://repo.fusesource.com/nexus/content/groups/ea
    
If you cannot reach that DNS name, you can try to ping the server directly from a box that can see it, and then
use the IP address directly (or add it to your hosts file). One scenario where this may come up is when you have to play around with the DNS entries on your box to be able to see the OSE installation you've set up.

Then you'll need to add the new proxy repo you just added to the _Public Repositories Group_



    

## What's Next?
You can [go right to the Demo](demo.md) or you can [set up Jenkins](set-up-jenkins.md) since that's the next container
that should be set up to do the demo.