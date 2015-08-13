#!/bin/bash
set -ex

function setup_ssh {
  sudo cp /opt/assets/sshd_config /etc/ssh/sshd_config
  sudo service ssh restart
}

function setup_users {
  sudo touch /etc/sudoers.d/10-users
  sudo chown root:root /etc/sudoers.d/10-users
  sudo chmod 400 /etc/sudoers.d/10-users
  for key in /opt/assets/public_keys/*; do
    user=$(basename $key)
    sudo adduser --disabled-password --gecos "" $user
    sudo gpasswd -a $user docker
    sudo mkdir -p /home/$user/.ssh
    sudo cp $key /home/$user/.ssh/authorized_keys
    sudo chmod 600 /home/$user/.ssh/authorized_keys
    sudo chown -R $user:$user /home/$user
    echo "$user ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/10-users
  done
  echo "
Defaults  env_reset
root  ALL=(ALL:ALL) ALL
%admin ALL=(ALL) ALL
%sudo ALL=(ALL:ALL) ALL
#includedir /etc/sudoers.d
" | sudo tee /etc/sudoers
}

function setup_registry {
  sudo chmod 777 /mnt
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
  echo "deb https://get.docker.io/ubuntu docker main" | sudo tee -a /etc/apt/sources.list.d/docker.list
  sudo mkdir -p /mnt/docker
  sudo ln -s /mnt/docker /var/lib/docker
  sudo cp /opt/assets/config/docker /opt/
  sudo apt-get update
  sudo apt-get install -y linux-image-extra-`uname -r`
  sudo apt-get install -y lxc-docker

  echo "export SETTINGS_FLAVOR=s3
export DOCKER_REGISTRY_CONFIG=/opt/docker/config.yml
export LOGLEVEL=warn" | sudo tee /opt/env.sh
  echo "start on runlevel [2345]
stop on runlevel [016]
limit nofile 65536 65536
script
  set -ex
  if [ -e /opt/env.sh ]; then
    . /opt/env.sh
  fi
  exec docker run -p 5000:5000 --name registry registry:2 2>&1
end script
respawn" | sudo tee /etc/init/registry.conf
}

setup_registry
setup_users
setup_ssh
