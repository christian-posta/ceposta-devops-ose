# Setting up Gerrit for the Continuous Delivery Demo
We use docker containers for all of the continuous deliver pieces, so follow the first section on setting up the
Docker container on your host. Docker isn't required if you wish to manually set up an environment somewhere else.

## Set up Docker container
For this container, we're using an image from the scripts in this project. So you'll need to have this project checked
out into a directory from now on referred to $PROJ_ROOT.

To build the Docker image, navigate to the `gerrit-docker` folder:

    cd $PROJ_ROOT/gerrit-docker
    
Then build the image using `gerrit` as the image name:

    docker build -t gerrit .
    
Now you should have an image of the gerrit installation we're going to use.

Run the container with this command:

    docker run -itdP --env GITLAB_USER=root --env GITLAB_PASSWORD=redhat01 --env GITLAB_PROJ_ROOT=root --name gerrit --link gitlab:gitlab gerrit
    
Note we link to the `gitlab` container, so this container must have been installed first. The username/password are
the credentials we set when creating our gitlab account. [See the GitLab setup instructions for more](set-up-gitlab.md).

Now you can run the following command to see where on the host Gerrit HTTP listener is installed:

    docker port gerrit 8080
    
    
## Set up Gerrit user account
The first person to log into gerrit becomes the administrator. Since we've set up Gerrit to be in developer mode we
won't use any fancy SSO signin. To see more about the config [checkout the Readme.md from the dockerfile](../gerrit-docker/Readme.md). You can "become" a specific user in this development mode, and the first account we
"become" will be the admin account. So click the "Become" link in the top right-hand corner. Then click
"New Account" under register:

---

![Gerrit Become](images/GerritBecome.png)

---

Now you'll need to enter the fields in this order (be careful, unforunately it's tricky)

1) Register New Email
2) Full Name
3) Enter a Username then click --> Select Username

At this point you can add SSH keys, but to keep it simple you can just HTTP access as well.

Click the _continue_ link at the bottom left hand side.

### Set up HTTP password
Before you keep going, you should set up an HTTP password so we can use the HTTP url with gerrit (of course this
is just for the demo. You __should__ use the SSH access in a real environment).

To do this, Click on your name in the upper right hand and select "settings"

On the left-hand side, you should see "HTTP Password" click that and generate a password:

---

![HTTP Password](images/GerritHttpPassword.png)

---

Now your user account is all setup...

## Prep the quickstart-fuse-rest project
Next we need to get the project set up. So just like we created a new project (empty one) on gitlab, we'll do the same
here for Gerrit. Click on "Projects" and then "Create New Project" The name of the project must match the name we
gave to the project in GitLab (because that's how the replication from Gerrit to GitLab happens) and we MUST use the name
__quickstart-fuse-rest__ because that's what's used in the Jenkins builds.

---

![Gerrit new project](images/GerritNewProject.png)

---

Now we need to import some code!! We'll check out the quickstart-fuse-rest code from GitHub:

    $ git clone <put url here>
    $ cd quickstart-fuse6.1-rest
    
Then we'll need to add the gerrit url as a remote:

    $ git remote add gerrit http://ceposta@ceposta-public:49166/quickstart-fuse-rest.git
    

Note you'll need to get the HTTP url from here:

---

![HTTP Url](images/GerritHttpAccess.png)

---

Now we need to configure the git-config with the same values we have in our Gerrit installation:

    git config user.name "Christian Posta"
    git config user.email "christian.posta@gmail.com"
    
Then we have to get the commit-msg hook that'll use for generating Change-Ids (which is what gerrit uses for tracking
changes:

    curl -Lo .git/hooks/commit-msg http://ceposta-public:49157/tools/hooks/commit-msg
    chmod +x .git/hooks/commit-msg
        
Note, the URL above to grab the commit-ms is the location of your gerrit installation and "/tools/hooks/commit-msg"

Now we should be ready to push to master (we'll pull first to rebase what's already in gerrit)

    git pull gerrit master
    git push gerrit master

### Verify replication happened correctly
At this point we have our quickstart-fuse-rest application installed into Gerrit, and since gerrit does repplication
to GitLab, we should see the same code in Gitlab as well. If this happened, everything is working correctly so far.

For me, the path to my Gitlab project is here:
    
    http://ceposta-public:49164/root/quickstart-fuse-rest/tree/master
    
Yours will be wherever you set up gitlab using the Gitlab docker container [as described in setting up Gitlab](set-up-gitlab.md)