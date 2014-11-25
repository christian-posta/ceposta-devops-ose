# Continuous Delivery with JBoss Fuse 6.1 and OpenShift Enterprise 2.1

This guide is intended for people who already are familar with running the demo end to end, but need 
a refresher.

## Make sure you can log into all of the services

* Use bootstrap/print-docker.sh to show the location of the docker services
* 

## Check out the project from Gerrit

* "Become" the _Administrator_ role and click on "projects-->list" click on "quickstart-fuse-rest"
* copy/paste the HTTP url (don't use Anonymous URL. You could use SSH url if you have the keys set up)
* the password is in the user settings under "HTTP Password" (click on your account, and then settings)
* now git clone from that http url (note, the username is in the url)..

Now we need to configure the git-config with the same values we have in our Gerrit installation:

    git config user.name "Administrator"
    git config user.email "admin@company.com"
    
Then we have to get the commit-msg hook that'll use for generating Change-Ids (which is what gerrit uses for tracking
changes:

    curl -Lo .git/hooks/commit-msg http://ceposta-public:49157/tools/hooks/commit-msg
    chmod +x .git/hooks/commit-msg
        
Note, the URL above to grab the commit-msg is the location of your gerrit installation and "/tools/hooks/commit-msg"
    
For code reviews, we push to this branch:

    git push origin HEAD:refs/for/master

## Make a change to the project and commit it to the code review branch

* Make a change to the Readme.md. I always choose that one, but can choose a code change if you like
* commit that change to the branch
* push the branch to the code review branch (HEAD:refs/for/master)
* Navigate to gerrit, and click on "My-->Changes" you should see your change in the "outgoing review" table, and you should see that there is a little "+1" in the "CR" column. This means Jenkins properly checked it out, built in, and voted
* Click on the change, and can poke around there
* Ultimately need to click "Review" and then "+2" and then "Publish and Submit"
* At this point, the code should be merged into the master branch that can be used for CI/CD. Go check the Gitlab project and check the commits. You should see your commit there. If you don't (wait a few minutes for it to replicated..) then something is screwed up. :)

## Kick off the Build pipeline 

* Now you can go to Jenkins. You should see the "fuse-rest-gerrit-patchset" build was successfully run. Now you manually go kickoff the build that will end up building out the OSE environments (broker.hosts.pocteam.com)
* NOTE #1: Make sure the fuse containers at pocteam.com are all deleted. The demo will fail if there are existing fuse installations.
* NOTE #2: Make sure the build artifacts/branches for the builds don't already exist in Gitlab/Nexus because this will fail the build. For example, some time we reset the jenkins and it will build at build #0... this will create a build #0 branch at gitlab and also try to upload version of the jars with "0" as part of the version number. If these branches or versions already exist, the build will fail

* Since we don't use a proper DNS entry for the pocteam.com site, we'll have to update the DNS entry so that the docker container can see it (this should be done ahead of the demo)
* Find the build labeled "fuse-rest-initial-build" and click on it, and hten "Build with Parameters" and accept the default major version number "1.0" ... (though you could change it) and click "Build"
* Now you can go back to the main Jenkins page and click on the "Build Pipeline" named "fuse-rest-pipeline"
* Now watch the build traverse through as well as watch the openshift enviornment on pocteam.com automatically get populated
* you can watch the "raw" console output to see that it's making progress
* When the "fuse-rest-deploy-dev" build is finished running, you can click on the build itself, find the "Environment Variables" link, and find the username/password for the fuse instance; you can then login and show it's a proper fuse deployment

Good luck!