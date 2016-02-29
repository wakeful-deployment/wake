# Wake

Wake packages, deploys, manages and orchestrates applications and application environments.

## Wake vs. Other Infrastructure Frameworks

Wake is an end-to-end solution for managing applications and application
environments from version control commit to running in production. Wake uses
other pluggable infrastructure frameworks such as Kubernetes or Docker Swarm
to power many of its features. In addition to the functionality that these
frameworks provider, Wake also offers other pluggable abstractions over IaaS
providers, logging and other common infrastructure needs.

# Prereqs

* docker
* docker-machine

_NOTE: On Windows, you'll need to ensure that OpenSSL has access to a certificate
authority bundle.  Download the [Mozilla Certificat bundle](https://raw.githubusercontent.com/bagder/ca-bundle/master/ca-bundle.crt)
locally, and set the `SSL_CERT_FILE` environment variable to reference this file._

You may also want to add wake's bin directory to your path for ease of use.

# Terms

**cluster**: a collection of nodes (servers) managed together as a unit

**node**: a server in the cluster

**process**: the smallest unit of work (e.g. a web server or background job)

**application**: is a list of related processes defined by a `manifest.json`

**service**: is the collection of all running instances of a process

# CLI conventions

Every command supports these three flags:

* `-v` or `--verbose` which will output lots of extra logging
  information
* `-V` or `--very-verbose` which will output a ton of extra logging
  information that is mostly unecessary
* `-h` or `--help` which will output the usage information

# Cluster

A cluster is a logical collection of nodes.

Clusters are kept track of in `~/.wake/clusters` and can be managed with
the `wake clusters` command.

## Create a cluster

```sh
$ wake clusters create --name wake-test-1 --iaas azure --location eastus
```

_NOTE: azure is the only supported IaaS provider at this time._

## List known clusters

```sh
$ wake clusters list
```

## Set the default cluster

Having a default cluster makes everything else easier, since almost
every other command will need to know which cluster to perform the
operation on (like creating a new host, where should it go?).

```sh
$ wake clusters set-default -n wake-test-1
```

## Delete a cluster

```sh
$ wake clusters delete -n wake-test-1
```

_NOTE: `wake-clusters-delete` will ask you to confirm the name of the
cluster before proceeding. It's possible to pass `--pre-confirm` with
the name again to prevent the confirmation prompt._

> *Environments*
>
> There are no environments with wake. Make a new cluster with a different name.

# Hosts

## Create a new bare host from ubuntu

```sh
$ wake hosts create --bare --name test-host-1
```

## Create a new host using the default host image for a cluster

For the default cluster:

```sh
$ wake hosts create --name test-host-1
```

For a specific cluster:

```sh
$ wake hosts create --name test-host-1 --cluster other-cluster
```

Wake will actually provide a random name for you if you like:

```sh
$ wake hosts create
```

To connect to a host after it's created:

```sh
$ wake hosts create --connect
```

## Connecting to a host

To connect to a host by it's name:

```sh
$ wake hosts connect -n test-host-1
```

To run a command on a host:

```sh
$ wake hosts run -n test-host-1 -c 'uptime'
```

# Application conventions

* Every process must listen on port 8000 for `/_health`
* Every app must declare it's dependencies so the proxy container on the
  host will fill in the correct ips and dns

# `manifest.json`

Here are some examples:

```json
{
  "platform": "ruby",
  "app": "bestsiteever",
  "owners": [
    "nathan.herald@microsoft.com"
  ],
  "processes": {
    "web": {
      "start": "cd /opt/app && bin/puma -c config/puma.rb",
      "cpu": 1,
      "memory": 0.5
    },
    "worker": {
      "start": "cd /opt/app && bundle exec rake jobs:work",
      "cpu": 1,
      "memory": 0.5
    }
  }
}
```

```json
{
  "platform": "sbt",
  "app": "proxy",
  "owners": [
    "nathan.herald@microsoft.com"
  ],
  "processes": {
    "proxy": {
      "cpu": 4,
      "memory": 4,
      "start": "cd /opt/app && sbt run"
    }
  }
}
```

# Containers

We build the docker containers by going through a few steps:

1. Detect the platform type
2. Build platfrom-compile container
3. For each process, use a process-application-compile < platform-compile container to:
   1. Compile a binary of the application process into /tmp/app.gz
   2. Render a Dockerfile that inherits from the application-release
   3. Build process-application-release:sha
   4. Extract /tmp/app.gz into the final container as /opt/app/*
   5. Copy /tmp/run to /opt/run

Yes, we build the final process-application-release:sha container inside
the process-application-compile one. This means that our compiled app is
compiled in linux and packaged up in linux. It also means it's easy to
copy files into the final container with simple ADD's and stuff like
that.

_NOTE: **Current status**: only creating the process-application-compile
container. We will eventually create the -release one, but it is
currently not a priority._

## OK, what's the command to build a container?

First change into the application's directory where the `manifest.json`
is, then:

```sh
$ wake containers create -r b5aedadd
```

If you want to push your containers to your docker hub organization,
first create the repo over on docker hub, then append `--push`:

```sh
$ wake containers create -r $(git rev-parse --verify HEAD | cut -c1-9) --push
```

## Azure

* Service principal is created and has the correct roles

_NOTE: There will be a tool to help setup a service principal
eventually. In the meantime please consult the azure ruby sdk README
for the most up to date information._

