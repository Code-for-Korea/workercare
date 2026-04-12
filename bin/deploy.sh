#!/bin/bash

set -e
echo -n "Docker Hub Username: "
read KAMAL_REGISTRY_USERNAME
echo ""
echo -n "Docker Hub Access Token: "
read -s KAMAL_REGISTRY_PASSWORD
echo ""
echo ""

if [ -z "$KAMAL_REGISTRY_PASSWORD" ]; then
  echo "Access Token is blank"
  exit 1
fi

export KAMAL_REGISTRY_USERNAME
export KAMAL_REGISTRY_PASSWORD

kamal setup
# kamal deploy

echo "Done"
