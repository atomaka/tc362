#!/bin/bash

# UPDATE SCRIPT - on a more clever day, I might merge this with bootstrap.sh
# Can take a single param to allow a specific branch to be installed
BRANCH=$1

# TO BE RUN AS ROOT
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
  echo "This script must be run as root"
  exit
fi

# CLONE PUPPET REPOSITORY
cd /tmp
rm -rf puppet
git clone https://github.com/atomaka/tc362.git puppet
cd puppet

if [ "$BRANCH" != "" ]; then
  git fetch
  git checkout $BRANCH
fi

# INSTALL MODULES
librarian-puppet install

# RUN MANIFEST
puppet apply manifests/site.pp --modulepath=modules/
