# USERS
# atomaka, with SSH key
user { 'atomaka':
  ensure     => present,
  groups     => ['sudo'],
  managehome => true,
  shell      => '/bin/zsh',
  require    => Package['zsh'],
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
  managehome => true,
  shell      => '/bin/bash',
  password   => '$6$.AURF9sE09Q$..S10CFY7G.AVXzSW//w6GoV6yPzBzdvyUl8a7oyYbW/XzBU.o6AdHxTgTkCSWb64zmN3QoKovoUyLJhE/MFP/'
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
class { 'apache': }

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

# FILES
file { '/var/www/index.html':
  ensure => present,
  content => file('/tmp/puppet/files/index.html'),
  require => Class['apache'],
}
