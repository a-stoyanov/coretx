# == Define: coretx::groups
#
# Group account definitions for coretx::identity	
#
define coretx::groups (

  $ensure               = undef,
  $allowdupe            = undef,
  $attribute_membership = undef,
  $attributes           = undef,
  $auth_membership      = undef,
  $forcelocal           = undef,
  $gid                  = undef,
  $ia_load_module       = undef,
  $members              = undef,
  $provider             = undef,
  $system               = undef,

)
{
  group { $name:
    ensure               => $ensure,
    allowdupe            => $allowdupe,
    attribute_membership => $attribute_membership,
    attributes           => $attributes,
    auth_membership      => $auth_membership,
    forcelocal           => $forcelocal,
    gid                  => $gid,
    ia_load_module       => $ia_load_module,
    members              => $members,
    provider             => $provider,
    system               => $system,
  }
}
