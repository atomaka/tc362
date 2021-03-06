# GROUPS
group { 'web':
  ensure => present,
}

# USERS
# atomaka, with SSH key
user { 'atomaka':
  ensure     => present,
  groups     => ['sudo', 'web', 'maverick', 'iceman', 'wordpress'],
  managehome => true,
  shell      => '/bin/zsh',
  require    => [
    Package['zsh'],
    Group['web'],
    User['maverick'],
    User['iceman'],
    User['wordpress'],
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
# jeff, with password
user { 'jeff':
  ensure     => present,
  groups     => ['web'],
  managehome => true,
  shell      => '/bin/bash',
  password   => '$6$.AURF9sE09Q$..S10CFY7G.AVXzSW//w6GoV6yPzBzdvyUl8a7oyYbW/XzBU.o6AdHxTgTkCSWb64zmN3QoKovoUyLJhE/MFP/',
  require    => Group['web'],
}
#maverick, iceman, and wordpress with no login
user { 'maverick':
  ensure => present,
  shell  => '/sbin/nologin',
}
user { 'iceman':
  ensure => present,
  shell  => '/sbin/nologin',
}
user { 'wordpress':
  ensure => present,
  shell  => '/sbin/nologin',
}

# PACKAGES
package { 'mosh': }
package { 'zsh': }
package { 'mailutils': }

# CLASSES
include augeas
include sudo

ssh::server::configline { 'Port': value => '22984' }
ssh::server::configline { 'PermitRootLogin': value => 'no' }
ssh::server::configline { 'PasswordAuthentication': value => 'yes' }
ssh::server::configline { 'AllowUsers/1': value => 'atomaka' }
ssh::server::configline { 'AllowUsers/2': value => 'jeff' }

class { '::ssh::server':
  storeconfigs_enabled       => false,
  options                    => {
    'Port'                   => [22984],
    'PermitRootLogin'        => 'no',
    'PasswordAuthentication' => 'yes',
    'AllowUsers/1'           => 'atomaka',
    'AllowUsers/2'           => 'jeff',
  },
}

class { '::apache':
  default_vhost => false,
  mpm_module    => 'prefork',
}
class { '::apache::mod::php': }

class { '::mysql::server': }
class { '::mysql::bindings':
  php_enable => true,
}

class { '::wordpress':
  wp_owner    => 'root',
  wp_group    => 'wordpress',
  install_dir => '/var/www/wordpress.atomaka.com',
}

# CONFIGURATIONS
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
apache::vhost { 'maverick.atomaka.com':
  port          => '80',
  docroot       => '/var/www/maverick.atomaka.com',
  docroot_owner => 'maverick',
  docroot_group => 'maverick',
}
apache::vhost { 'iceman.atomaka.com':
  port          => '80',
  docroot       => '/var/www/iceman.atomaka.com',
  docroot_owner => 'iceman',
  docroot_group => 'iceman',
}
apache::vhost { 'wordpress.atomaka.com':
  port          => '80',
  docroot       => '/var/www/wordpress.atomaka.com',
  docroot_owner => 'wordpress',
  docroot_group => 'wordpress',
}

# FILES
file { '/var/www/tc362.atomaka.com':
  ensure  => directory,
  owner   => 'atomaka',
  group   => 'web',
  mode    => '2775',
  source  => '/tmp/puppet/files/tc362',
  recurse => true,
  before  => Apache::Vhost['tc362.atomaka.com'],
}
file { '/var/www/maverick.atomaka.com':
  ensure  => directory,
  owner   => 'maverick',
  group   => 'maverick',
  mode    => '2775',
  source  => '/tmp/puppet/files/maverick',
  recurse => true,
  before  => Apache::Vhost['maverick.atomaka.com'],
}
file { '/var/www/iceman.atomaka.com':
  ensure  => directory,
  owner   => 'iceman',
  group   => 'iceman',
  mode    => '2775',
  source  => '/tmp/puppet/files/iceman',
  recurse => true,
  before  => Apache::Vhost['iceman.atomaka.com'],
}

file { '/home/atomaka/web':
  ensure  => link,
  owner   => 'atomaka',
  group   => 'atomaka',
  target  => '/var/www/tc362.atomaka.com',
  require => [ User['atomaka'], File['/var/www/tc362.atomaka.com'] ],
}
file { '/home/atomaka/maverick':
  ensure  => link,
  owner   => 'atomaka',
  group   => 'atomaka',
  target  => '/var/www/maverick.atomaka.com',
  require => [ User['atomaka'], File['/var/www/maverick.atomaka.com'] ],
}
file { '/home/atomaka/iceman':
  ensure  => link,
  owner   => 'atomaka',
  group   => 'atomaka',
  target  => '/var/www/iceman.atomaka.com',
  require => [ User['atomaka'], File['/var/www/iceman.atomaka.com'] ],
}
file { '/home/atomaka/wordpress':
  ensure  => link,
  owner   => 'atomaka',
  group   => 'atomaka',
  target  => '/var/www/wordpress.atomaka.com',
  require => [ User['atomaka'], File['/var/www/wordpress.atomaka.com'] ],
}

file { '/home/jeff/web':
  ensure  => link,
  owner   => 'jeff',
  group   => 'jeff',
  target  => '/var/www/tc362.atomaka.com',
  require => [ User['jeff'], File['/var/www/tc362.atomaka.com'] ],
}

file { '/etc/profile':
  ensure  => present,
  content => file('/tmp/puppet/files/profile'),
  require => Package['mailutils'],
}
