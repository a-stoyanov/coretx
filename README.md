# puppet-module-coretx

## Description

A collection of parameterized classes for common resource management on Linix clients. Designed and tested for use with an ENC.
Supported OS list: RHEL/CentOS/Debian/Ubuntu.


## What does this module do?
Class coretx::identity - Manage user and group resources. User definition includes multiple SSH keys management via erb template.
Class coretx::cronjob - Manage user and system-wide (/etc/crontab) cron jobs. System crontab is managed via erb template.
Class coretx::fsmounts - Manage file system mounts resources (/etc/fstab).
Class coretx::root - Manage the root super user account. Includes multiple SSH keys management via erb template (~/.ssh/authorized_keys).
Class coretx::hosts - Manage the hosts file (/etc/hosts) via erb template.
Class coretx::files - Manage file/folder resources.
Class coretx::yumrepos - Manage yum repositories on RedHat systems.
Class coretx::packages - Manage generic package resources states.
Class coretx::services - Manage generic service resource states.


## Compatibility
This module supports Puppet v4 and above.

Tested on:
* RedHat EL 5/6/7
* Debian 6/7/8
* Ubuntu 16


## Installing the module
puppet module install astoyanov-coretx


## Usage

## Class coretx::identity
Manage user account and group resources - This class will overwrite individual user $home/.ssh/authorized_keys files!
Resource documentation (user): https://docs.puppet.com/puppet/latest/types/user.html
Resource documentation (group): https://docs.puppet.com/puppet/latest/types/group.html

### Parameters

#### users_hash
Hash parameter which can be used for multi user resource management via create_resources().
Resource documentation (user): https://docs.puppet.com/puppet/latest/types/user.html

- *Default*: {}
- *Note*: The 'managehome' key/value is required for each nested user hash you want to trigger use of the SSH keys template
- *Examples(YAML)*:

<pre>
---
coretx::identity:
  users_hash:
    john:
      name: john
      ensure: present
      comment: Group admin
      groups:
      - sudo
      - nix-admins
      password: '$1$324dfdsg$WIrstQFASIpxo3yy4Xjg80'
    sysadmin:
      name: sysadmin
      ensure: present
      home: '/home/sysadmin'
      managehome: true
      comment: System administrator
      password_max_age: 90
      password_min_age: 1
      expiry: '2020-12-30'
      groups:
      - sudo
      - nix-admins
      password: '$1$324dfdsg$WIrstQFASIpxo3yy4Xjg80'
      ssh_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfzq9TjTKQvylLeTkuCf9pE== root@localhost
    testuser2:
      name: testuser2
      ensure: present
      managehome: true
      home: '/var/home/testuser2'
      comment: This is a test user
      ssh_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfzq9TjTKQvylLeTkuCf9pE95rc== testuser2@localhost
      - ecdsa-sha2-nistp256 BBBBB3NzaC1yc2EAAAADAQABAAABAQDfzq9TjTKQvylLeTkuCf9== testuser2@localhost
</pre>

#### users_defaults
Hash parameter which can be used to provide some default key values for $users_hash create_resources().

- *Default*: {}
- *Examples(YAML)*:

<pre>
---
coretx::identity:
  users_defaults:
    managehome: true
    groups:
	- staff
	- nix-admins
</pre>

#### groups_hash
Hash parameter which can be used for multi group resource management via create_resources().
Resource documentation (group): https://docs.puppet.com/puppet/latest/types/group.html

- *Default*: {}
- *Examples(YAML)*:

<pre>
---
coretx::identity:
  groups_hash:
    staff:
      name: staff
      ensure: present
    nix-admins:
      name: nix-admins
      ensure: present
      gid: 2001
</pre>

#### home_dir_parents
Hash parameter which can be used for multi folder resource management via create_resources().
You can use this to create parent directories for home folders if needed.
Resource documentation (file): https://docs.puppet.com/puppet/latest/types/file.html

- *Default*: {}
- *Note*: No recursion when creating directories, have to specify in hashed order
- *Examples(YAML)*:

<pre>
---
coretx::identity:
  home_dir_parents:
    /var/home:
      ensure: directory
      owner: root
      mode: '0774'
    /var/home/pub:
      ensure: directory
      owner: root
      mode: '0774'
</pre>


## Class coretx::cronjob
Manage user and system-wide Cron jobs (/etc/crontab) - This class will overwrite your system Crontab file!
Resource documentation (cron): https://docs.puppet.com/puppet/latest/types/cron.html

### Parameters

### user_cronjobs_hash
Hash parameter which can be used for multi user cron job resource management via create_resources()
Writes cron entries in individual user crontabs.

- *Default*: {}
- *Note*: Ommited time key/values ('minute', 'hour', etc) default to '*'. Ommited 'user' key/value defaults to 'root'
- *Examples(YAML)*:

<pre>
---
coretx::cronjob:
  user_cronjobs_hash:
    testjob1:
      name: testjob1
      hour: 12
      minute: 0
      user: root
      command: reboot
    testjob2:
      name: testjob2
      hour: 0
      minute: 15
      weekday: 1
      user: sysadmin
      command: 'bash /var/scripts/montly-report.sh'
</pre>

### crontab_jobs_hash
Hash parameter which can be used for system Crontab file (/etc/crontab) management via erb template.
If this parameter is supplied a hash input, the class will detect the client OS (RedHat/Debian/Ubuntu) and write out a default template (coretx/crontab_deb.erb or coretx/crontab_el.erb)

- *Default*: {}
- *Note*: Ommited time schedule keys ('minute', 'hour', etc) default to '*'. Ommited 'user' key defaults to 'root'
- *Examples(YAML)*:

<pre>
---
coretx::cronjob:
  crontab_jobs_hash:
    testjob1:
      name: testjob1
      hour: 12
      minute: 0
      user: root
      command: reboot
    testjob2:
      name: testjob2
      hour: 0
      minute: 15
      weekday: 1
      user: sysadmin
      command: 'bash /var/scripts/montly-report.sh'
</pre>

### override_crontab_template
String parameter which can be used to override what template to use - e.g when you are attempting to use this class on a client OS other than RedHat/Debian/Ubuntu.
You can also supply your own template, just need to copy it to the coretx/templates plugin folder.

- *Default*: 'use_defaults'
- *Examples*: 'coretx/crontab_deb.erb' , 'coretx/crontab_el.erb'

### override_crontab_path
String parameter which can be used to override what PATH value to use on a provided template.
The class will detect and supply defaults for the client OS - RedHat/Debian/Ubuntu.

- *Default*: 'use_defaults'
- *Example*: '/usr/local/sbin:/usr/local/bin'

### override_crontab_shell
String parameter which can be used to override what SHELL value to use on a provided template.
The class will detect and supply defaults for the client OS - RedHat/Debian/Ubuntu.

- *Default*: 'use_defaults'
- *Example*: '/bin/sh'

### override_cron_service
String parameter which can be used to specify what CRON service name value is in use on the system for service ensure/enable states and refresh triggers.
The class will detect and supply defaults for the client OS - RedHat/Debian/Ubuntu.

- *Default*: 'use_defaults'
- *Examples*: 'cron' , 'crond'

### crond_ensure
String parameter which can be used to specify the ensure state of the CRON service.

- *Default*: 'running'
- *Examples*: 'running' , 'stopped'

### crond_enable
Boolean parameter which can be used to specify the enable state of the CRON service.

- *Default*: true
- *Examples*: true , false

## Class coretx::fsmounts
Manage the filesystem mount states (/etc/fstab)
Resource documentation (mount): https://docs.puppet.com/puppet/latest/types/mount.html

### Parameters

### fsmounts_hash
Hash parameter which can be used to manage entries in (/etc/fstab) via create_resources().

- *Default*: {}
- *Note*: Some fs types require extra supporting packages installed on the system - e.g. nfs requires nfs-utils
- *Examples(YAML)*:

<pre>
---
coretx::fsmounts:
  fsmounts_hash:
    /mnt/exports:
      name: /mnt/exports
      ensure: mounted
      device: 192.168.99.200:/data
      fstype: nfs
      remounts: true
      options: ro
    /mnt/remote:
      name: /mnt/remote
      ensure: mounted
      device: 192.168.100.200:/data
      fstype: nfs
      remounts: true
      options: rw	  
</pre>

### fsmounts_dir_hash
Hash parameter which can be used for mount directory management via create_resources().
You can use this to create the mount directories on the local system, if needed.

- *Default*: {}
- *Note*: No recursion when creating directories. Hash directory resources are created before $fsmounts_hash mount resources
- *Examples(YAML)*:

<pre>
---
coretx::fsmounts:
  fsmounts_dir_hash:
    /mnt/exports:
      name: /mnt/exports
      ensure: directory
    /mnt/remote:
      name: /mnt/remote
      ensure: directory
      owner: root
      mode: '0775'  
</pre>

### default_fsmounts_ensure
String parameter which can be used to specify the default 'ensure' key values in $fsmounts_hash

- *Default*: 'mounted'
- *Examples*: 'mounted' , 'unmounted' , 'present' , 'absent'

### default_fsmounts_options
String parameter which can be used to specify the default 'options' key value. 
You can specify multiple options in the same key as a single String, comma separated.
Check man pages for more details mount(8).

- *Default*: 'defaults'
- *Examples*: 'defaults' , 'rw' , 'ro' , 'suid' , 'dev' , 'exec' , 'auto' , 'nouser' , 'async' etc.

### default_fsmounts_remounts
Boolean parameter which can be used too specify the default 'remounts' key value

- *Default*: true
- *Examples*: true , false


## Class coretx::root
Manage the root superuser.
Resource documentation (user): https://docs.puppet.com/puppet/latest/types/user.html

### Parameters

### root_ssh_keys
Hash parameter which can be used to specify ssh keys in via provided erb template.
Overwrites the specified SSH keys file! (Default: /etc/.ssh/authorized_keys)

- *Default*: {}
- *Examples(YAML)*:

<pre>
---
coretx::root:
  root_ssh_keys:
    Foreman Puppet-Master:
      ssh-keys:
      - ecdsa-sha2-nistp256 BBBBB3NzaC1yc2EAAAADAQABAAABAQDfzq9TjTKQvylLeTkuCf9+BDaQgHCyAUEehLxJW6AkDa== foreman@localhost
      - ssh-rsa zaC1yc2EAAAABJQAAAQEAqOk3yrDBjG9AGk2uGgQvE8nL7wEfZiLLo1CQ57m72a6B+U4A2qZ4Oz8d== foreman-proxy@localhost
    John Smith:
      ssh-keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAqOk3yrDBjG9AGRmJVE4cpfcA/3lpjuZmZ4e0QRnRWPxQzhvC02U4+HpQ== jsmith@localhost
    James Allen:
      ssh-keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAABJQAGV6yY5Tej1AiAV8Dvc7jmX92IxFZ5I1EdcY5l3YKcd7yJKvjBgW0kic== jallen@localhost
</pre>

### root_ssh_dir
String parameter which can be used to specify the ssh keys directory to create inside /root home directory.

- *Default*: '.ssh'
- *Example*: any qualified dir name as a string

### root_ssh_keys_file
String parameter which can be used to specify the ssh keys file name to create inside /root/$root_ssh_dir directory.

- *Default*: 'authorized_keys'
- *Examples*: any qualified file name as a string

### root_purge_ssh_keys
Boolean parameter which can be used to purge the SSH keys file contents for the root user.

- *Default*: false
- *Note*: Setting this key value to true will only have effect if $root_ssh_keys hash is empty
- *Examples*: true , false

### root_acc_expiry
Use this String parameter to specify the root account expiry date.

- *Default*: undef
- *Example*: '2020-12-30'

### root_passwd_hash
String parameter which can be used to specify the root account password in encrypted hashed format.
You can generate a salted encrypted password with the following:

<pre>
openssl passwd -1 -salt SomeRandomSaltString
</pre>

- *Default*: undef
- *Example*: '$1$324dfdsg$WIrstQFASIpxo3yy4Xjg80'

### root_passwd_max_age
String parameter which can be used to specify the root account password max age parameter in days as decimal.

- *Default*: undef
- *Example*: '90'

### root_passwd_min_age
String parameter which can be used to specify the root account password min age parameter in days as decimal.

- *Default*: undef
- *Example*: '1'


## Class coretx::hosts
Manage the hosts file (/etc/hosts) via erb template - This class will overwrite your hosts file!
Based off module chrekh/puppet-hosts - origin project url: https://github.com/chrekh/puppet-hosts
This class makes use of a custom fact (coretx/lib/facter/list_addrs.rb)

### Parameters

### hosts_file_entries
A hash with additional host file entries to add. Entries in this hash override automatic host entries for IP's on local interfaces.
The content can be either comment => { ip => [ names ], ... } or just ip => [ names ].

- *Default*: {}
- *Examples(YAML)*:

<pre>
---
coretx::hosts:
  hosts_file_entries:
    Foreman:
      192.168.99.250:
      - foreman-dev.lab.local
      - puppet
      - puppet.lab.local
    Service nodes:
      192.168.99.251:
      - nfs-node1
      192.168.99.252:
      - nfs-node2
</pre>

### hosts_file
String parameter to specify the hosts file location.

- *Default*: '/etc/hosts'

### lo_names4
List of names for localhost ip4 loopback.

- *Default*: [ 'localhost.localdomain', 'localhost', 'localhost4.localdomain4', 'localhost4' ]

### lo_names6
List of names for localhost ip6 loopback.

- *Default*: [ 'localhost.localdomain', 'localhost', 'localhost6.localdomain6', 'localhost6' ]

### primary_ipv4
List of IPv4 addresses. Empty list means no entry.

- *Default*: [ IPv4 addresses derived from local fact (no loopback or multicast) ]

### primary_ipv6
List of IPv6 addresses. Empty list means no entry.

- *Default*: [ IPv6 addresses derived from local fact, defaults to linklocal if no global scope assigned to interface (no loopback or multicast) ]

### primary_names
List of names for primary addresses.

- *Default*: [ $::fqdn, $::hostname ]

### one_primary_ipv4
If true, only use the first address from primary_ipv4

- *Default*: true

### one_primary_ipv6
If true, only use the first address from primary_ipv6

- *Default*: true


## Class coretx::files
Manage file resources on client systems
Resource documentation (file): https://docs.puppet.com/puppet/latest/types/file.html
Resource documentation (file_line): https://forge.puppet.com/puppetlabs/stdlib#file_line

### Parameters

### files_hash
Hash parameter which can be used for multi file/folder resource management via create_resources()
You can put your own custom source files inside the coretx/files plugin directory and include them via with a 'source' key/value.

- *Default*: {}
- *Examples(YAML)*:

<pre>
---
coretx::files:
  files_hash:
    clientbucket.rb:
      name: clientbucket.rb
      path: '/root/clientbucket.rb'
      source: puppet:///modules/coretx/clientbucket.rb
    my_test_script.sh:
      name: my_test_script.sh
      path: '/var/scripts/my_test_script.sh'
      content: 'mysqldump -usysadmin --password=mypass --single-transaction > /backup/mysqlbackup_${date}.sql'
      owner: sysadmin
      mode: '0700'
</pre>

### file_line_hash
Hash parameter which can be used to supply arguments to the file_line() stdlib function via create_resources().
The file_line() function can be used to modify line content in files by using regex match/replace.

- *Default*: {}
- *Examples(YAML)*:

<pre>
---
coretx::files:
  file_line_hash:
    '/etc/newrelic/nrsysmond.cfg':
      path: '/etc/newrelic/nrsysmond.cfg'
      match: "^license_key="
      line: license_key=77f3fds0ZcsdfSA12400lNMc
</pre>

### create_parent_dirs
Boolean parameter which controls whether the class should also create the parent directories in $files_hash.
If true, scan the $files_hash parameter supplied hash for all "path" key/values and run a "mkdir -p" against each value.
Ensures all parent directories are created recursively.

- *Default*: false
- *Examples*: true , false

### default_files_ensure
String parameter used as default value for $files_hash 'ensure' keys.
Can be overridden by specifying the 'ensure' key for each individual nested hash in $files_hash.

- *Default*: 'present'
- *Examples*: 'present' , 'absent' , 'file' , 'directory' etc.

### default_files_owner
String parameter which can be used for specifying the default 'owner' key value for all nested hashes in $files_hash.

- *Default*: undef

### default_files_group
String parameter which can be used for specifying the default 'group' key value for all nested hashes in $files_hash.

- *Default*: undef

### default_files_mode
String parameter which can be used for specifying the default 'mode' key value for all nested hashes in $files_hash.

- *Default*: undef


## Class coretx::yumrepos
Manage yum repository definitions for the RedHat family.
Resource documentation (yumrepo): https://docs.puppet.com/puppet/latest/types/yumrepo.html

### Parameters

### yumrepo_hash
Hash parameter which can be used to manage multiple yum repository resources via create_resources().

- *Default*: {}
- *Examples(YAML)*:

<pre>
---
coretx::yumrepos:
  yumrepo_hash:
    newrelic-repo:
      descr: Newrelic Yum repository
      baseurl: https://yum.newrelic.com/pub/newrelic/el5/x86_64/
    puppet-pc1-el7:
      descr: Puppet Labs PC1 Repository el 7
      baseurl: http://yum.puppetlabs.com/el/7/PC1/$basearch
      enabled: 1
      gpgcheck: 0
</pre>

### default_yumrepo_enable
String parameter which can be used for specifying the default 'enable' key value for all nested hashes in $yumrepo_hash.

- *Default*: 1

### default_gpgcheck_enable
String parameter which can be used for specifying the default 'gpgcheck' key value for all nested hashes in $yumrepo_hash.

- *Default*: 0


## Class coretx::packages
Manage software package states.
Resource documentation (package): https://docs.puppet.com/puppet/latest/types/package.html

### Parameters

### packages_hash
Hash parameter which can be used to manage multiple package resources via create_resources().

- *Default*: {}
- *Examples(YAML)*:

<pre>
---
coretx::packages:
  packages_hash:
    nfs-utils:
      name: nfs-utils
      ensure: latest
    newrelic-sysmond:
      name: newrelic-sysmond
      ensure: purged
</pre>

### packages_hash_defaults
Hash parameter which can be used to specify default keys/values for $packages_hash input.

- *Default*: {}
- *Examples(YAML)*:

<pre>
---
coretx::packages:
  packages_hash_defaults:
    ensure: latest
</pre>


## Class coretx::services
Manage existing service states.
Resource documentation (service): https://docs.puppet.com/puppet/latest/types/service.html

### Parameters

### services_hash
Hash parameter which can be used to manage the state of multiple (existing) service resources via create_resources().

- *Default*: {}
- *Examples(YAML)*:

<pre>
---
coretx::services:
  services_hash:
    sshd:
      name: sshd
      enable: true
      ensure: running
    open-vm-tools:
      name: open-vm-tools
      enable: false
      ensure: stopped
</pre>

### default_service_ensure
String parameter which can be used for specifying the default 'ensure' key value for all nested hashes in $services_hash.

- *Default*: running
- *Examples*: stopped , running

### default_service_enable
Boolean parameter which can be used for specifying the default 'enable' key value for all nested hashes in $services_hash.

- *Default*: true
- *Examples*: true , false
