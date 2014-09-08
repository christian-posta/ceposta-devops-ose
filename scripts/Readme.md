# OpenShift autmation scripts
These scripts are used to spin up new environments (using OSE cartridges) in an OpenShift Enterprise (OSE) environment.

[create_ose_env.sh](create_ose_env.sh) is the script that's called by the Jenkins build, but you can try out the
script (or its major pieces, which are the python scripts) outside of Jenkins also.

Some of the variables are hard coded at the moment, but we can change that.

To run the create_ose_env.sh script, pass in the name of the app along with the version to use. Note,
OSE will strip out the '.' characters:

    $ create_ose_env.sh 1.0.2
    

Once the script finishes, you should see the environment details in the ./vars/ folder with a name like:

    openshift_vars_build_102
    
You can also check the Jenkins fuse-rest-deploy-dev job to see how it's used.

NOTE you'll have to have your DNS set up so that the OSE installation can be resolved. 

For example, in this demo, we use an OSE installation setup here:

    broker.hosts.pocteam.com

This would require the following resolv info:


    domain pocteam.com
    nameserver 209.132.178.95