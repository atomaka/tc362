# GROUPS
group { 'web':
  ensure => present,
}

# USERS
# atomaka, with SSH key
user { 'atomaka':
  ensure     => present,
  groups     => ['sudo', 'web'],
  managehome => true,
  shell      => '/bin/zsh',
  require    => [ Package['zsh'], Group['web'] ]
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
# jeff, with password
user { 'jeff':
  ensure     => present,
  groups     => ['web'],
  managehome => true,
  shell      => '/bin/bash',
  password   => '$6$.AURF9sE09Q$..S10CFY7G.AVXzSW//w6GoV6yPzBzdvyUl8a7oyYbW/XzBU.o6AdHxTgTkCSWb64zmN3QoKovoUyLJhE/MFP/',
  require    => Group['web'],
}

# PACKAGES
package { 'mosh': }
package { 'zsh': }

# CLASSES
include augeas
include sudo

class { 'ssh::server':
  require => Class['augeas'],
}

class { 'apache':
  default_vhost => false,
}

# CONFIGURATIONS
ssh::server::configline { 'Port': value => '22984' }
ssh::server::configline { 'PermitRootLogin': value => 'no' }
ssh::server::configline { 'PasswordAuthentication': value => 'yes' }
ssh::server::configline { 'AllowUsers/1': value => 'atomaka' }
ssh::server::configline { 'AllowUsers/2': value => 'jeff' }

sudo::conf { 'sudo':
  priority => 10,
  content  => "%sudo ALL=(ALL) NOPASSWD: ALL\n",
}

apache::vhost { 'tc362.atomaka.com':
  default_vhost => true,
  port          => '80',
  docroot       => '/var/www/tc362.atomaka.com',
  docroot_owner => 'atomaka',
  docroot_group => 'web',
}

# FILES
file { '/var/www/tc362.atomaka.com':
  ensure => directory,
  owner  => 'atomaka',
  group  => 'web',
  mode   => '2775',
  before => Apache::Vhost['tc362.atomaka.com'],
}

file { '/var/www/tc362.atomaka.com/index.html':
  ensure  => present,
  owner   => 'atomaka',
  group   => 'web',
  mode    => '0664',
  content => file('/tmp/puppet/files/index.html'),
  require => File['/var/www/tc362.atomaka.com'],
}

file { '/home/atomaka/web':
  ensure  => link,
  owner   => 'atomaka',
  group   => 'atomaka',
  target  => '/var/www/tc362.atomaka.com',
  require => [ User['atomaka'], File['/var/www/tc362.atomaka.com'] ],
}

file { '/home/jeff/web':
  ensure  => link,
  owner   => 'jeff',
  group   => 'jeff',
  target  => '/var/www/tc362.atomaka.com',
  require => [ User['jeff'], File['/var/www/tc362.atomaka.com'] ],
}
