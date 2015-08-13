# wake deploys

Wake packages, deploys, and manages applications and application
environemnts.

# Prereqs

* packer

# Terms

**host**: a virtual server running a docker host (sometimes called an
_instance_)

**cluster**: is a collection of hosts managed together and registerd in
a consul registry

**application**: is a collection of processes defined by a
`manifest.json` and stored in a git repo

**instance**: is a running application hosted in a container on a host
in a cluster

**container**: a docker container

# ???

Wake packages applications into containers which can be deployed
into a cluster. Wake uses consul to keep track of hosts and applications
in a cluster. Basically a cluster is a consul master with 0 or more
registered hosts and 0 more registered applications on those hosts.

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

# How do I run a web app then?

Launch some instances that listen on a port and then either:

* Register them in a public load balancer
* Use DNS to round robin their IPs
* Use a static IP to point to a haproxy or nginx instance that renders
  the IPs of the application instances

# Let's deploy wordpress

First, let's create a new cluster.

```sh
$ wake clusters:create --name best-cluster
+ some output
```

We can check how many hosts and instances we have now:

```sh
$ wake hosts | wc -l
4

$ wake hosts
i-87a3bc2        c3.large          ec2-54-74-246-42.eu-west-1.compute.amazonaws.com        eu-west-1a        1 min
i-97a3bc2        c3.large          ec2-54-74-246-49.eu-west-1.compute.amazonaws.com        eu-west-1b        1 min
i-47a3bc2        c3.large          ec2-54-74-246-48.eu-west-1.compute.amazonaws.com        eu-west-1c        1 min
i-07a3bc2        c3.large          ec2-54-74-246-47.eu-west-1.compute.amazonaws.com        eu-west-1a        1 min
```

We can also see all the instances:

```sh
$ wake instances
consul-master        9158ad25c39ad745a04ae3544ee462b0fc15fe90        i-87a3bc2        1 min       healthy
consul-slave         9158ad25c39ad745a04ae3544ee462b0fc15fe90        i-97a3bc2        1 min       healthy
consul-slave         9158ad25c39ad745a04ae3544ee462b0fc15fe90        i-47a3bc2        1 min       healthy
rsyslog-master       11420f6d407d7c1f7e6bac1f89fb1ba081cb7c1b        i-07a3bc2        1 min       healthy
```

By default, wake will not allow any instances that belong to the same
application to reside on the same host. Also, some applications are defined
to use a lot of resources (consul and rsyslog are two). This is why we
ended up with 4 hosts for 4 applications. As we launch more applications
they will begin to share resources on hosts.

Now we can pack up our app for deployment. We need to make a
`manifest.json` in our app's repo:

```json
{
  "platform": "php",
  "name": "bestsiteever",
  "owner": [
    "nathan.herald@microsoft.com"
  ],
  "repos": [],
  "types": {
    "web": {
      "cpu": 1,
      "memory": 256,
      "processes": {
        "consul_client": "/opt/bin/consul agent -config-dir /opt/config/consul.d/",
        "statsite": "/opt/bin/statsite -f /opt/config/statsite.d/default.ini",
        "nginx": "/opt/bin/nginx -c /opt/bin/nginx/php-default.conf"
      },
      "cron_jobs": []
    }
  }
}
```

The default configs are setup for best practices and it's best to use
them unless absolutuly necessary. An example manifest for a rails
application would look like:


```json
{
  "platform": "rails",
  "name": "aufgaben",
  "owner": [
    "nathan.herald@microsoft.com"
  ],
  "repos": [],
  "types": {
    "web": {
      "cpu": 1,
      "memory": 256,
      "processes": {
        "consul_client": "/opt/bin/consul agent -config-dir /opt/config/consul.d/",
        "statsite": "/opt/bin/statsite -f /opt/config/statsite.d/default.ini",
        "nginx": "/opt/bin/nginx -c /opt/bin/nginx/rails-default.conf",
        "rails": "bin/puma -C /opt/app/rails/puma_config.rb"
      },
      "cron_jobs": []
    },
    "worker": {
      "cpu": 1,
      "memory": 256,
      "processes": {
        "task_toucher": "bin/rails runner app/consumers/task_toucher.rb"
      },
      "cron_jobs": []
    }
  }
}
```

Now that we have a manifest we can pack up our code:

```sh
$ wake pack
+ some output
cd4e1f4cba4c928557542d8ad34f46c0e567c632
```

The result sha is the docker container that has the runtime and code
packed up and ready to go.

Now, to launch one of these into your default cluster run:

```sh
$ wake launch -s cd4e1f4cba4c928557542d8ad34f46c0e567c632 -n 1
+ some output
```

This will first look for an empty spot on a host with enough spare cpu
and memory (one does not exist so it will then create a new host) and
then launch the container onto one host in the cluster.

If we were to make an update to our code we would simply run:

```sh
$ wake pack
+ some output
a440880e801db4e91a7a51be11e516263ec954fd
```

and then

```sh
$ wake replace -s a440880e801db4e91a7a51be11e516263ec954fd
```

`wake replace` first runs `wake count`, then will launch that amount of
new instances, then it will run `wake contract` for the same amount of
instances. Since `wake contract` removes oldest instances first this
means the end result is only new instances are running.


