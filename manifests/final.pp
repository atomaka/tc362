# Create a non root user with sudo permissions
# jeff, with password
user { 'jeff':
  ensure     => present,
  groups     => ['sudo'],
  managehome => true,
  shell      => '/bin/bash',
  password   => '$6$.AURF9sE09Q$..S10CFY7G.AVXzSW//w6GoV6yPzBzdvyUl8a7oyYbW/XzBU.o6AdHxTgTkCSWb64zmN3QoKovoUyLJhE/MFP/',
}

class { '::ssh::server':
  storeconfigs_enabled => false,
  options              => {
    # Logging in with the root user must be disabled
    'PermitRootLogin'  => 'no',
    # SSH must be enabled on a non-standard port
    'Port'             => [22984],
  },
}

# Install a working MySQL server
class { '::mysql::server': }

# A fully functioning Ruby on Rails installation must be present at your domain
# name or IP address using the Nginx web server (must show the Rails welcome
# page)
# You may use any Rails deployment that works with Nginx

# install nginx
class { 'nginx': }

# configure nginx proxy
nginx::resource::upstream { 'welcome_app':
  members => ['localhost:3000'],
}
nginx::resource::vhost { 'final.atomaka.com':
  proxy => 'http://welcome_app',
}

# install rails
package { 'rails':
  provider => 'gem',
}

# add rails depends
package { ['libsqlite3-dev', 'build-essential', 'nodejs']:
  before => Exec['install rails app']
}

# add rails user and application
user { 'rails':
  ensure     => present,
  groups     => ['sudo'],
  managehome => true,
  shell      => '/bin/bash',
}
exec { 'create rails app':
  command     => 'rails new welcome',
  user        => 'rails',
  environment => ['HOME=/home/rails'],
  path        => '/usr/bin:/usr/local/bin',
  cwd         => '/home/rails',
  creates     => '/home/rails/welcome',
  require     => [
    Package['rails'],
    User['rails'],
  ],
}
exec { 'install rails app':
  command     => 'bundle install --path vendor/bundle',
  user        => 'rails',
  environment => ['HOME=/home/rails'],
  path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  cwd         => '/home/rails/welcome',
  unless      => 'bundle check',
  require     => Exec['create rails app'],
  notify      => Exec['start rails app'],
}
exec { 'start rails app':
  command     => 'rails server -d',
  user        => 'rails',
  environment => ['HOME=/home/rails'],
  path        => '/usr/bin:/usr/local/bin',
  cwd         => '/home/rails/welcome',
  refreshonly => true,
}

# A working firewall using iptables or another Linux firewall
resources { 'firewall':
  purge => true,
}
class { '::firewall':
  require => Class['::ssh::server'],
}
firewall { '000 accept all icmp':
  proto  => 'icmp',
  action => 'accept',
} ->
firewall { '001 accept all to lo interface':
  proto   => 'all',
  iniface => 'lo',
  action  => 'accept',
}->
firewall { '002 accept related established rules':
  proto   => 'all',
  state   => ['RELATED', 'ESTABLISHED'],
  action  => 'accept',
}->
firewall { '100 accept ssh (non-default port)':
  proto  => 'tcp',
  dport  => '22984',
  action => 'accept',
} ->
firewall { '200 accept http':
  proto  => 'tcp',
  dport  => '80',
  action => 'accept',
}

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
