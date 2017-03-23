# == Class: coretx::files
#
# Manage file resources on client systems
# Resource documentation (file): https://docs.puppet.com/puppet/latest/types/file.html
# Resource documentation (file_line): https://forge.puppet.com/puppetlabs/stdlib#file_line
#
class coretx::files (
  
  Hash $files_hash                      = {},
  Hash $file_line_hash                  = {},
  Boolean $create_parent_dirs           = false,
  String $default_files_ensure          = 'present',
  Optional[String] $default_files_owner = undef,
  Optional[String] $default_files_group = undef,
  Optional[String] $default_files_mode  = undef,

)
{
  require coretx::packages

  $file_defaults = {
    ensure => $default_files_ensure,
    owner  => $default_files_owner,
    group  => $default_files_group,
    mode   => $default_files_mode,
  }

# Scan $files_hash for all "path" keys, extract and create parent directories from each value
  if $create_parent_dirs == true {
    $files_hash.each |$key, $value| {
      $value_sort = $value.filter |$key1, $value1| { $key1 =~ /path$/ }
        $value_sort.each |$key2, $value2| {
          $parent_path = regsubst($value2, '^(/.+/).+', '\1')
            if ! defined(Exec["mkdir_p-${parent_path}"]) {
              exec { "mkdir_p-${parent_path}":
                command => "mkdir -p ${parent_path}",
                unless  => "test -d ${parent_path}",
                path    => '/bin:/usr/bin',
              }
            }
        }
    }
  }
  
  create_resources(file, $files_hash, $file_defaults)
  create_resources(file_line, $file_line_hash)
}
