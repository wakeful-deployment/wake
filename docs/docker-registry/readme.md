# Docker Registry

The following details how to run your own docker registry for the purposes of
using it with Wake.

For this documentation we will use Microsoft Azure as our example cloud
computing and storage provider and Ubuntu as the host operating system.

For how to tweak this set up for other providers (e.g. Amazon Web Services) or
operating systems refer to the official Docker documentation.

## Setting up a registry

* Create a cloud server:

Using Azure's CLI or web interface create a virtual machine running Ubuntu.
Remember to allow port 443 open in the security settings.

* Create the storage backend:

Using Azure's CLI or web service create an Azure blob storage that will be used as the backend storage.

* Set up docker on the cloud server:

On the server install docker.

`$ wget -qO- https://get.docker.com/ | sh`

* Run the docker registry container:

Remember to set enviroment variables or replace all variables (e.g.  `$ACCOUNTNAME`)

```
$ sudo docker run -d -p 5000:5000 \
  -e REGISTRY_STORAGE_AZURE_ACCOUNTNAME=$ACCOUNTNAME \
  -e REGISTRY_STORAGE_AZURE_ACCOUNTKEY=$ACCOUNTKEY
  -e REGISTRY_STORAGE_AZURE_CONTAINER=$CONTAINERNAME \
  -e REGISTRY_STORAGE=azure \
  --restart=always --name registry registry:2
```

## Running Nginx

* Download nginx:

```
$ sudo apt-get update
$ sudo apt-get install nginx
```

* Confirm you have > version 1.7.5

```
$ nginx -v
```

* Configure nginx :

Replace the default nginx server config (`/etc/nginx/sites-enabled/default`):

```
server {
  listen 443;

  ssl on;
  ssl_certificate /certs/public.cert;
  ssl_certificate_key /certs/private.key;

  add_header Strict-Transport-Security "max-age=31536000; includeSubdomains";
  proxy_set_header  Host              $http_host;   # required for docker client's sake
  proxy_set_header  X-Real-IP         $remote_addr; # pass on real client's IP

  # disable any limits to avoid HTTP 413 for large image uploads
  client_max_body_size 0;

  # make sure the client knows always to use version 2 of the API
  add_header 'Docker-Distribution-Api-Version' 'registry/2.0' always;

  # required to avoid HTTP 411: see Issue #1486 (https://github.com/docker/docker/issues/1486)
  chunked_transfer_encoding on;

  location / {
    # add basic auth
    auth_basic "Restricted";
    auth_basic_user_file /etc/nginx/auth/registry.password;

    proxy_pass  http://localhost:5000;
  }

  location /_ping {
    auth_basic off;
    proxy_pass  http://localhost:5000;
  }

  location /v1/_ping {
    auth_basic off;
    proxy_pass  http://localhost:5000;
  }
}
```

Docker registry should always be run with TLS support. Make sure to use a
trusted certificate authority and add your certificates to the place specified
in the nginx config.

You should also use basic auth for authentication. Unfortunately there is a bug
in how docker registry handles authentication (https://github.com/docker/distribution/issues/655).
It is recommended to use SHA-2 for generating the basic auth password.
