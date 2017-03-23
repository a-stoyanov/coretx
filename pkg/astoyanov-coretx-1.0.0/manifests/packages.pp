# == Class: coretx::packages
#
# Manage software package states
# Resource documentation (package): https://docs.puppet.com/puppet/latest/types/package.html
#
class coretx::packages (

  Hash $packages_hash          = {},
  Hash $packages_hash_defaults = {},

)
{
  require coretx::yumrepos
  create_resources(package, $packages_hash, $packages_hash_defaults)
}
