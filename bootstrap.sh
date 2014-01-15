#!/bin/bash

# TO BE RUN AS ROOT
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
  echo "This script must be run as root"
  exit
fi

# SET TIMESTAMP
echo "America/New_York" | tee /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

# UPGRADE ALL CURRENT PACKAGES
apt-get upgrade -y && apt-get dist-upgrade -y

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

# CLONE PUPPET REPOSITORY
cd /tmp
git clone https://github.com/atomaka/tc362.git puppet

# INSTALL MODULES
cd puppet
librarian-puppet install

# RUN MANIFEST
puppet apply manifests/site.pp --modulepath=modules/
