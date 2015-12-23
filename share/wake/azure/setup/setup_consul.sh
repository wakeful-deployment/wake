#!/bin/bash

set -e
set -x

mv operator.json /opt/config/operator.json
chown root:root -R /opt/config
chmod 644 -R /opt/config

# pre-pull all known global images

images=$(jq -a -r ".boot_images | map(.image) | .[]" /opt/config/operator.json)

for image in $images; do
  docker pull $image
done
