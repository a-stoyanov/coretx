# == Class: coretx::root
#
# Manage the root superuser
# Resource documentation (user): https://docs.puppet.com/puppet/latest/types/user.html	
#
class coretx::root (

  Hash $root_ssh_keys                   = {},
  String $root_ssh_dir                  = '.ssh',
  String $root_ssh_keys_file            = 'authorized_keys',
  Boolean $root_purge_ssh_keys          = false,
  Optional[String] $root_acc_expiry     = undef,
  Optional[String] $root_passwd_hash    = undef,
  Optional[String] $root_passwd_max_age = undef,
  Optional[String] $root_passwd_min_age = undef,

)
{
  user { 'root':
    ensure           => present,
    home             => '/root',
    expiry           => $root_acc_expiry,
    password         => $root_passwd_hash,
    password_max_age => $root_passwd_max_age,
    password_min_age => $root_passwd_min_age,
    purge_ssh_keys   => $root_purge_ssh_keys,
  }

  if !empty(root_ssh_keys) {
    file { "/root/${root_ssh_dir}":
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0700',
    }
    file { "/root/${root_ssh_dir}/${root_ssh_keys_file}":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => template('coretx/authorized_keys_root.erb'),
    }
  }
}
