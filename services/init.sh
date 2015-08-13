#!/bin/bash
set -ex

app=$1
rev=$3
servertype=$4
export APP=$app
export REV=$rev
export SERVERTYPE=$servertype
echo $app > /opt/app_name
echo $rev > /opt/app_rev
echo $servertype > /opt/app_servertype

mkdir -p /opt/app /opt/bin

if [[ "$(ls -A /opt/assets/sv)" ]]; then
  cp -R /opt/assets/sv/* /etc/service/
  find /etc/service -name "run" | xargs chmod +x
fi
if [[ -e /opt/assets/env.sh ]]; then
  cp /opt/assets/env.sh /opt/env.sh
  chmod +x /opt/env.sh
fi
if [[ -e /opt/assets/crontab ]]; then
  crontab /opt/assets/crontab
else
  rm -rf /etc/service/cron
fi
if [[ "$(ls -A /opt/assets/repos)" ]]; then
  cp -R /opt/assets/repos/* /opt/
fi
if [[ -d /opt/assets/src ]]; then
  mkdir -p /opt/src
  cp -R /opt/assets/src/* /opt/src/*
fi
if [[ -e /opt/assets/database.yml ]] && [[ -d /opt/app/config ]]; then
  mkdir -p /opt/app/config # why make it if it already exists?
  cp /opt/assets/database.yml /opt/app/config
fi

if [[ "$(ls -A /opt/assets/bin)" ]]; then
  cp /opt/assets/bin/* /opt/bin/
fi
chmod +x /opt/bin/*

chown -R app:app /opt/
apt-get clean
echo "export PATH=$PATH:/opt/bin" >> /opt/env.sh
