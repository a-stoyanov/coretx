# == Class: coretx::fsmounts
#
# Manage the filesystem mount states (/etc/fstab)
# Resource documentation (mount): https://docs.puppet.com/puppet/latest/types/mount.html
#
class coretx::fsmounts (

  Hash $fsmounts_hash                = {},
  Hash $fsmounts_dir_hash            = {},
  String $default_fsmounts_ensure    = 'mounted',
  String $default_fsmounts_options   = 'defaults',
  Boolean $default_fsmounts_remounts = true,

)
{
  $fsmounts_defaults = {
    ensure   => $default_fsmounts_ensure,
    options  => $default_fsmounts_options,
    remounts => $default_fsmounts_remounts,
  }

  $fsmounts_dir_defaults = {
    ensure   => directory,
  }

  create_resources(file, $fsmounts_dir_hash, $fsmounts_dir_defaults)
  create_resources(mount, $fsmounts_hash, $fsmounts_defaults)
}
