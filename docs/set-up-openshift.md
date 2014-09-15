# Setting up OpenShift Enterprise for the Continuous Delivery Demo

Setting up OSE is a little beyond the scope of this demo guide, but there are a few important assumptions
made about the OSE environment:

* OSE has an `xpaas` profile that is set up to be able to run the Fuse cartridge correctly
* There is a cartridge named "fuse-1.0.0" available that represents the Fuse cart
* There is a domain named `dev` into which we'll deploy the carts. In an actual set up, we should really
have a separate domain per build
* The username/password for the account used for the demo is "christian/christian" but the params can be
changed in the [create_ose_env.sh](../ose-scripts/create_ose_env.sh) script
* That the nameservers for the OSE environment are registered on the Docker host so that the jenkins container
can pick up the correct nameserver to be able to communicate with the OSE broker
