# ENV

* Need to remove all traces of the production environment

# go

* Download and install all the dependencies directly?
    * connecty
    * consul
    * logger
    * openssl
    * statsite

# consul

* Defaults should be 1 and localhost
* Replace encrypt variable somehow
* Replace the service.json file somehow

# statsite

* Replace the librato.ini somehow

# cluster

* Need to setup consul and record the ip/dns of the master
* Need to setup rsyslog and record the ip/dns of the master

# registry

* Need a place to configure the hostname and auth of the docker registry

# render

* MakeExecutable needs to be outsourced to the repo (`make executable` or something like that)
* render needs to be a public repo
* `wake setup` should download and install render
* Add a way to "include source" that will just insert the current project's git repo into tmp/src
