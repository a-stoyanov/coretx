# == Class: coretx::identity
#
# Manage user account and group resources - This class will overwrite individual user $home/.ssh/authorized_keys files!		
# Resource documentation (user): https://docs.puppet.com/puppet/latest/types/user.html
# Resource documentation (group): https://docs.puppet.com/puppet/latest/types/group.html
#
class coretx::identity (

  Hash $users_hash       = {},
  Hash $users_defaults   = {},
  Hash $groups_hash      = {},
  Hash $home_dir_parents = {},  
)
{ 
  create_resources(file, $home_dir_parents)
  create_resources(coretx::groups, $groups_hash)
  create_resources(coretx::users, $users_hash, $users_defaults) 
}
