#!/bin/bash

# BOOSTRAP SCRIPT
# Can take a single param to allow a specific branch to be installed

usage() { echo "Usage: $0 [-s] [-m MANIFEST_FILE] [BRANCH]" 1>&2; exit 1; }

while getopts "sm:" o; do
  case "${o}" in
    s)
      SETUP=true
      ;;
    m)
      MANIFEST=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

BRANCH=$1

# TO BE RUN AS ROOT
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
  echo "This script must be run as root"
  exit
fi

if [ "$SETUP" = true ] ; then
  # SWAPFILE
  dd if=/dev/zero of=/swapfile bs=1024 count=512k
  mkswap /swapfile
  swapon /swapfile

  # SET TIMESTAMP
  echo "America/New_York" | tee /etc/timezone
  dpkg-reconfigure --frontend noninteractive tzdata

  # UPGRADE ALL CURRENT PACKAGES
  apt-get update && apt-get upgrade -y

  # INSTALL GIT
  apt-get install git -y

  # INSTALL RUBYGEMS
  apt-get install rubygems -y

  # INSTALL PUPPET
  wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
  dpkg -i puppetlabs-release-precise.deb
  apt-get update
  apt-get install puppet -y

  gem install librarian-puppet
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
puppet apply manifests/$MANIFEST --modulepath=modules/
