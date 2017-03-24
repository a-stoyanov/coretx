# == Class: coretx::hosts
#
# Manage the hosts file (/etc/hosts) via erb template - This class will overwrite your hosts file!
# Based off module chrekh/puppet-hosts - origin project url: https://github.com/chrekh/puppet-hosts
# This class makes use of a custom fact (coretx/lib/facter/list_addrs.rb)
# 
class coretx::hosts (

  Hash $hosts_file_entries  = {},
  String $hosts_file        = '/etc/hosts',
  String $hosts_file_group  = 'root',
  Array $lo_names4          = [ 'localhost.localdomain', 'localhost', 'localhost4.localdomain4', 'localhost4' ],
  Array $lo_names6          = [ 'localhost.localdomain', 'localhost', 'localhost6.localdomain6', 'localhost6' ],
  Boolean $one_primary_ipv4 = true,
  Boolean $one_primary_ipv6 = true,
  Array $primary_ipv4       = split($ipv4_pri_addrs,' '),
  Array $primary_ipv6       = split($ipv6_pri_addrs,' '),
  Array $primary_names      = [ $::fqdn, $::hostname ],

)
{
  if empty($ipv4_pri_addrs) and empty($primary_ipv4) {
    $pri_ipv4 = [ $::ipaddress ]
  }
  else {
    $pri_ipv4 = $one_primary_ipv4 ? {
      true    => [ $primary_ipv4[0] ],
      default => $primary_ipv4,
    }
  }

  if empty($ipv6_pri_addrs) and empty($primary_ipv6) {
    $pri_ipv6 = [ $::ipaddress6 ]
  }
  else {
    $pri_ipv6 = $one_primary_ipv6 ? {
      true    => [ $primary_ipv6[0] ],
      default => $primary_ipv6,
    }
  }

  file { $hosts_file:
    ensure  => present,
    owner   => 'root',
    group   => $hosts_file_group,
    mode    => '0644',
    content => template('coretx/hosts.erb'),
  }
}
