define wls_plugins::extract (
  $wls_zip_1 = undef,
  $wls_zip_2 = undef,
  $wls_installer_dir = '/opt/was/oracle/installers',
  $wls_installer_source = '/tmp/webhosting/Weblogicfiles',
  $wls_user = 'webadmin',
  $wls_group = 'webadmns',
) {

  file { "/opt/was/oracle/installers/${name}":
    ensure => directory,
    owner  => $wls_user,
    group  => $wls_group,
  }

  exec { "extract ${name} ${wls_zip_1}":
    cwd     => "/opt/was/oracle/installers/${name}",
    command => "unzip ${wls_installer_source}/${wls_zip_1}",
    creates => "/opt/was/oracle/installers/${name}/Disk1",
    path    => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:',
    user    => $wls_user,
    group   => $wls_group,
  }

  if $wls_zip_2 != undef {
    exec { "extract ${name} ${wls_zip_2}":
      cwd     => "/opt/was/oracle/installers/${name}",
      command => "unzip ${wls_installer_source}/${wls_zip_2}",
      creates => "/opt/was/oracle/installers/${name}/Disk3",
      path    => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:',
      user    => $wls_user,
      group   => $wls_group,
    }
  }

}
