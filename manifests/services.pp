# == Class: coretx::services
#
# Manage existing service states
# Resource documentation (service): https://docs.puppet.com/puppet/latest/types/service.html
#
class coretx::services (

  Hash $services_hash             = {},
  String $default_service_ensure  = 'running',
  Boolean $default_service_enable = true,

)
{
  $service_defaults = {
    ensure => $default_service_ensure,
    enable => $default_service_enable,
  }

  create_resources(service, $services_hash, $service_defaults)
}
