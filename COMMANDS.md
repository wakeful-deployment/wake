# Commands

Wake commands are run as sub commands to the `wake` binary. An
example is `wake info` which runs `wake-info`.

Commands are expected to be run in the application's git repo's
directory. All commands support `-a app-name` for being run from
any directory and support `--cluster cluster-name` for interacting with
more than one cluster at a time.

All commands also support `--json` which is great for automation.

## `wake commands`

List all these commands. Example output:

```sh
application         Outputs application info
application:new     Setup a new application manifest.json
```

## `wake help`

Show help for a command.

```sh
$ wake help application
```

## `wake application`

Outputs application info. Example output:

```sh
app: aufgaben
revision: 708bb86dc09b939455ac4448f3c4cd3bc0e0c87e
```

## `wake application:new`

Setup a new application's manifest.json. This commands guides one
through the setup process.

## `wake pack`

Users packer to create and store a docker container for a specific revision.
The `manifest.json` dictates the `platform` seed container used.

Streams logs and outputs any warnings or errors to stderr. Stdout
outputs the container's sha.

Exmaple output:

```sh
+ some stuff
+ some other stuff
+ registering in docker registry
708bb86dc09b939455ac4448f3c4cd3bc0e0c87e
```

## `wake seed`

Create a seed container for a platform.

## `wake config`

Read the configured environment variables for an application.

```sh
$ wake config
```

Example output:

```sh
RABBIT_URL=amqp://localhost
REDIS_URL=redis://localhost/11
```

If one needs these on one line, then one can use `xargs`:

```sh
wake config | xargs
```

Example output:

```sh
RABBIT_URL=amqp://localhost REDIS_URL=redis://localhost/11
```

If one needs to export these vars then interpolate them:

```sh
$ export $(wake config | xargs)
```

## `wake config:set`

Set environment variables for an application.

```sh
$ wake config:set RABBIT_URL=amqp://localhost REDIS_URL=redis://localhost/11
```

## `wake hosts`

List the hosts in the current cluster.

## `wake hosts:create`

Will create some amount of new hosts to accept containers.

## `wake hosts:find-or-create`

Will search for enough hosts to satisfy a query or create an appropriate
amount. Returns host ids and their capacities.

## `wake hosts:terminate`

Terminate a host using the PaaS apis.

## `wake clusters`

List all known clusters and some info about each.

## `wake clusters:create`

Create a new cluster which spins up a consul master/slaves and an
rsyslog instance.

## `wake instances`

List all instances in the current cluster.

## `wake instances:create`

Runs `wake hosts:find-or-create`, then places instances on the hosts
returned.

## `wake instances:terminate`

## `wake current-container`

## `wake launch`

```sh
wake launch -n 3 -i 708bb86dc09b939455ac4448f3c4cd3bc0e0c87e
```

Will run `instances:create`.

Accepts the optional flag `--replace` which will run `contract` for the
same amount after a successful launch.

## `wake contract`

Will reduce the number of running instances by a certain amount.

```sh
$ wake contract -n 1
```

## `wake expand`

Will increaes the number of running instances by a certain amount.

```sh
$ wake expand -n 1
```

## `wake count`

Outputs the numner of instances. Example output:

```sh
5
```
## `wake scale`

```sh
$ wake scale -n 15
```

Runs `count` and then runs either `expand` or `contract` to arrive at
the specified amount of instances for the current application.

## `wake terminate`

Removes instances from the cluster.

## `wake tail`

Stream logs from the rsyslog master.

- - -

## `wake chaos`

Destroys some ratio of all machines.

```sh
$ wake chaos -r 0.1
```

## `wake register`

Creates an entry in a remote awake instance for an application.
Remotely: a bare git repo is created, an entry in a database for keeping
track of the repo, the app, commits, and deploys.

## `wake github`

Setup and link wake to one's github account. This command will guide one
through the process.

## `wake keys`

Manage ssh keys for a remote awake instance.

## `wake browse`

Open the current app in a remote awake instance in a browser.

## `wake pgextras` (plugin)

## `wake rabbitmq` (plugin)

## `wake aws` (plugin)

## `wake azure` (plugin)

## `wake run`

## `wake up` (also `wake update`)

