# wake deploys

Wake packages, deploys, and manages applications and application
environemnts.

# Prereqs

* docker
* docker-machine

# Terms

**host**: a virtual server running a docker host (sometimes called an
_instance_ or a _node_)

**cluster**: is a collection of hosts managed together and registered in
a consul registry

**application**: is a list of processes defined by a `manifest.json` and
stored in a git repo

**instance**: is a running application process hosted in a container on
a host in a cluster

**container**: a docker container

# WTF???

Wake packages application's processes into containers which can be
deployed into a cluster. Wake uses consul to keep track of hosts and
applications in a cluster. Basically a cluster is a consul master with 0
or more registered hosts and 0 more registered application processes on
those hosts.

# Cluster

A cluster is comprised of at least these instances on hosts:

* consul master
* 2 consul slaves
* rsyslog master

Clusters are kept track of in `~/.wake/clusters.json` and can be managed
with the `wake clusters` command. Adding a new cluster is as easy as
finding the IP of the consul master and having permission to send
commands and queries to it.

# Environments

There are no environments with wake. Make a new cluster with a different
name.

# Conventions

* Every process must listen on port 8000 for `/_health`
* Every app must declare it's dependencies so the proxy container on the
  host will fill in the correct ips and dns

# `manifest.json`

Here is a good, full example:

```json
{
  "platform": "ruby",
  "name": "bestsiteever",
  "owner": [
    "nathan.herald@microsoft.com"
  ],
  "repos": {
    "/opt/cache-buster": "git@github.com/nathan-ms/cache-buster.git"
  },
  "processes": {
    "web": {
      "chdir": "/opt/app",
      "run": "bin/puma -c config/puma.rb",
      "cpu": 1,
      "memory": 512
    },
    "worker": {
      "chdir": "/opt/app",
      "run": "bundle exec rake jobs:work",
      "cpu": 1,
      "memory": 512
    }
  },
  "cron_jobs": [
    {
      "run": "*/10 * * * * /opt/cache-buster/bin/bust-caches",
      "cpu": 0.5,
      "memory": 256
    }
  ]
}
```

# Containers

We build the docker containers by going through a few steps:

1. Detect the platform type
2. Build platfrom-compile container
3. Build platform-release container
4. Build application-compile < platform-compile
5. Build application-release < platform-release
   (including dependencies, repos, and ENV vars)
6. For each process, use the application-compile container to:
   1. Compile a binary of the application process into /tmp/app.gz
   2. Render a Dockerfile that inherits from the application-release
   3. Build process-application-release:sha
   4. Extract /tmp/app.gz into the final container as /opt/app/*
   5. Copy /tmp/run to /opt/run

Yes, we build the final process-application-release:sha container inside
the application-compile one. This means that our compiled app is
compiled in linux and packaged up in linux. It also means it's easy to
copy files into the final container with simple ADD's and stuff like
that
