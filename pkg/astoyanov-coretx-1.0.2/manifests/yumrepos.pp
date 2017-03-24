# == Class: coretx::yumrepos
#
# Manage yum repository definitions for the RedHat family
# Resource documentation (yumrepo): https://docs.puppet.com/puppet/latest/types/yumrepo.html
#
class coretx::yumrepos (

  Hash $yumrepo_hash              = {},
  String $default_yumrepo_enable  = '1',
  String $default_gpgcheck_enable = '0',

)
{
  $yumrepo_defaults = {
    enabled  => $default_yumrepo_enable,
    gpgcheck => $default_gpgcheck_enable,
  }
  create_resources(yumrepo, $yumrepo_hash, $yumrepo_defaults)
}
