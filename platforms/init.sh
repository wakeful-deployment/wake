#!/bin/bash

set -xe

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

apt-get update
apt-get -q -y upgrade
apt-get update

apt-get install -y ngrep

adduser --home /opt/ --disabled-password --gecos "" app
mkdir -p /opt/bin /opt/src /opt/config

rm -rf /etc/service/syslog-forwarder /etc/service/syslog-ng

. /opt/assets/platforms/${1}.sh
