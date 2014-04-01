# Create a non root user with sudo permissions
# jeff, with password
user { 'jeff':
  ensure     => present,
  groups     => ['sudo'],
  managehome => true,
  shell      => '/bin/bash',
  password   => '$6$.AURF9sE09Q$..S10CFY7G.AVXzSW//w6GoV6yPzBzdvyUl8a7oyYbW/XzBU.o6AdHxTgTkCSWb64zmN3QoKovoUyLJhE/MFP/',
}

# Logging in with the root user must be disabled
include augeas
class { '::ssh::server':
  require => Class['augeas'],
}
ssh::server::configline { 'PermitRootLogin': value => 'no' }

# SSH must be enabled on a non-standard port
ssh::server::configline { 'Port': value => '22984' }

# Install a working MySQL server
class { '::mysql::server': }

# A fully functioning Ruby on Rails installation must be present at your domain
# name or IP address using the Nginx web server (must show the Rails welcome
# page)
# You may use any Rails deployment that works with Nginx

# install nginx
class { 'nginx': }

# A working firewall using iptables or another Linux firewall
resources { 'firewall':
  purge => true,
}
class { '::firewall': }
firewall { '000 accept all icmp':
  proto  => 'icmp',
  action => 'accept',
} ->
firewall { '100 accept ssh (non-default port)':
  proto  => 'tcp',
  dport  => '22984',
  action => 'accept',
} ->
firewall { '200 accept http':
  proto  => 'tcp',
  dport  => '80',
  action => 'accept',
} ->
firewall { '999 drop all':
  proto  => 'all',
  action => 'drop',
  before => undef,
}

# STUFF OUTSIDE SCOPE OF ASSIGNMENT
# convenience stuff
package { 'mosh': }
package { 'zsh': }

# atomaka, with SSH key
user { 'atomaka':
  ensure     => present,
  groups     => ['sudo'],
  managehome => true,
  shell      => '/bin/zsh',
  require    => [
    Package['zsh'],
  ],
}
file { '/home/atomaka/.ssh':
  ensure  => directory,
  owner   => 'atomaka',
  group   => 'atomaka',
  mode    => '0700',
  require => User['atomaka'],
}
file { '/home/atomaka/.ssh/authorized_keys':
  ensure  => present,
  owner   => 'atomaka',
  group   => 'atomaka',
  mode    => '0600',
  content => file('/tmp/puppet/files/keys/atomaka'),
  require => File['/home/atomaka/.ssh'],
}

# sudo no password
include sudo
sudo::conf { 'sudo':
  priority => 10,
  content  => "%sudo ALL=(ALL) NOPASSWD: ALL\n",
}
