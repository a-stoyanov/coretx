# == Class: coretx::cronjob
#
# Manage user and system-wide Cron jobs (/etc/crontab) - This class will overwrite your system Crontab file!
# Resource documentation (cron): https://docs.puppet.com/puppet/latest/types/cron.html
#
class coretx::cronjob (

  Hash $user_cronjobs_hash          = {},
  Hash $crontab_jobs_hash           = {},
  String $crond_ensure              = 'running',
  Boolean $crond_enable             = true,
  String $override_crontab_shell    = 'use_defaults',
  String $override_crontab_path     = 'use_defaults',
  String $override_crontab_template = 'use_defaults',
  String $override_cron_service     = 'use_defaults',

)
{
# OS defaults for /etc/crontab
  case $::osfamily {
    /^(RedHat)$/: {
      $crontab_shell_default    = '/bin/bash'
      $crontab_path_default     = '/sbin:/bin:/usr/sbin:/usr/bin'
      $crontab_template_default = 'coretx/crontab_el.erb'
      $cron_service_default     = 'crond'
    }
    /^(Debian|Ubuntu)$/: {
      $crontab_shell_default    = '/bin/sh'
      $crontab_path_default     = '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
      $crontab_template_default = 'coretx/crontab_deb.erb'
      $cron_service_default     = 'cron'
    }
    default: {
      if $override_crontab_template == use_defaults or $override_crontab_template == undef {
        $crontab_template       = 'coretx/crontab_deb.erb'
        $cron_service           = 'cron'
        fail("System crontab file template only tested on RedHat/Debian. Detected osfamily is <${::osfamily}>. Set appropriate override_ variables for your system to use a template")
      }
      else {
        $crontab_shell    = $override_crontab_shell
        $crontab_path     = $override_crontab_path
        $crontab_template = $override_crontab_template
        $cron_service     = $override_cron_service
        warning("Detected osfamily is <${::osfamily}>. Overrides set - template file: <${override_crontab_template}>; shell: <${override_crontab_shell}>; path: <${override_crontab_path}>; cron service: <${override_cron_service}>")
      }
    }
  }

  if $override_crontab_template != use_defaults {
    $crontab_template = $override_crontab_template
  }
  else {
    $crontab_template = $crontab_template_default
  }

  if $override_crontab_shell != use_defaults {
    $crontab_shell = $override_crontab_shell
  }
  else {
    $crontab_shell = $crontab_shell_default
  }

  if $override_crontab_path != use_defaults {
    $crontab_path = $override_crontab_path
  }
  else {
    $crontab_path = $crontab_path_default
  }

  if $override_cron_service != use_defaults {
    $cron_service = $override_cron_service
  }
  else {
    $cron_service = $cron_service_default
  }

  service { $cron_service:
    ensure => $crond_ensure,
    enable => $crond_enable,
  }

  if !empty($user_cronjobs_hash) {
    create_resources(cron, $user_cronjobs_hash)
  }

  if !empty($crontab_jobs_hash) {
    file { '/etc/crontab':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template($crontab_template),
      notify  => Service[$cron_service],
    }
  }
}
