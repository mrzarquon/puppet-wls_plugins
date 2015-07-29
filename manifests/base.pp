class wls_plugins::base {

  contain wls_plugins::sysctl

  $wls_packages = [
    'mount.nfs',
    'gcc',
    'glibc.i686',
    'libXext.i686',
    'libXtst.i686',
    'libaio.i686',
    'libaio-devel',
    'libaio-devel.i686',
    'glibc-devel.i686',
    'glibc-devel',
    'compat-libcap1',
  ]

  package { $wls_packages:
    ensure => latest,
  }

  $wls_directories = [
    '/opt/was/',
    '/opt/was/oracle',
    '/opt/was/oracle/installers',
    '/opt/was/oracle/installers/logs',
  ]

  file { $wls_directories:
    ensure  => directory,
    owner   => 'webadmin',
    group   => 'webadmns',
    mode    => '0644',
    require => [
      User['webadmin'],
      Group['webadmns'],
    ],
  }
 
  file { ['/opt/product', '/opt/product/java']:
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0644',
  }

  user { 'webadmin':
    ensure => present,
    groups => 'webadmns',
  }
  group { 'webadmns':
    ensure => present,
  }

} 
