#!/bin/bash

set -e
set -x

mv operator.json /opt/config/operator.json
chown root:root -R /opt/config
chmod 644 -R /opt/config
