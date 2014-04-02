#! /bin/bash

set -e

if sudo docker ps | grep "voodootikigod/riak-json" >/dev/null; then
  sudo docker ps | grep "voodootikigod/riak-json" | awk '{ print $1 }' | xargs -r sudo docker kill >/dev/null
  echo "Stopped the cluster and cleared all of the running containers."
fi
