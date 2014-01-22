# USERS
user { 'atomaka':
  ensure     => 'present',
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
ssh::server::configline { 'PasswordAuthentication': value => 'no' }
ssh::server::configline { 'AllowUsers/1': value => 'atomaka' }

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
