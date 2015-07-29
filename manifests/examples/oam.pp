class wls_plugins::examples::oam (
  $wls_user = 'webadmin',
  $wls_group = 'webadmns',
  $wls_java = 'jdk1.7.0_72',
  $wls_java_dir = '/opt/product/java/',
  $wls_middleware_home = '/opt/was/oracle/oam/middleware',
  $wls_domain_dir = "${wls_middleware_home}/wlserver_10.3",
  $wls_oracle_idm_home = "${wls_middleware_home}/Oracle_IDM1",
) {

  $wls_java_home = "${wls_java_dir}/${wls_java}"
  $wls_java_bin = "${wls_java_home}/bin/java"

  contain wls_plugins::base

  # we aren't using a file resource because we don't want the mount
  # to have to be present
  exec { 'copy wls installer':
    command   => '/bin/cp /tmp/webhosting/Weblogicfiles/wls1036_generic.jar /opt/was/oracle/installers/wls1036_generic.jar',
    creates   => '/opt/was/oracle/installers/wls1036_generic.jar',
    user      => 'webadmin',
    logoutput => true,
    require   => File['/opt/was/oracle/installers/'],
  }

  wls_plugins::java { 'jdk1.7.0_72': 
    wls_java_dir         => '/opt/product/java/',
    wls_java_installer   => '/tmp/webhosting/Weblogicfiles/jdk-7u72-linux-x64.tar.gz',
  }

  file { '/usr/java/latest':
    ensure  => link,
    target  => $wls_java_home,
    require => Wls_plugins::Java['jdk1.7.0_72'],
  }

  file { '/opt/was/oracle/installers/silent_weblogic_install_oam.xml':
    ensure  => file,
    owner   => $wls_user,
    group   => $wls_group,
    mode    => '0640',
    content => template('wls_plugins/silent_weblogic_install_oam.erb'),
    require => File['/opt/was/oracle/installers'],
  }
  
  wls_plugins::install { 'oam': 
    wls_java          => 'jdk1.7.0_72',
    wls_java_dir      => '/opt/product/java/',
    wls_plugin_dir    => '/opt/was/oracle/oam',
    wls_installer     => '/opt/was/oracle/installers/wls1036_generic.jar',
    wls_installer_dir => '/opt/was/oracle/installers',
    wls_logs          => '/opt/was/oracle/installers/logs/weblogic_install_oam.log',
    wls_answers       => '/opt/was/oracle/installers/silent_weblogic_install_oam.xml',
    wls_user          => 'webadmin',
    wls_group         => 'webadmns',
    require           => File['/opt/was/oracle/installers/silent_weblogic_install_oam.xml'],
  }

  wls_plugins::extract { 'idm':
    wls_zip_1            => 'ofm_iam_generic_11.1.1.7.0_disk1_1of2.zip',
    wls_zip_2            => 'ofm_iam_generic_11.1.1.7.0_disk1_2of2.zip',
    wls_installer_dir    => '/opt/was/oracle/installers',
    wls_installer_source => '/tmp/webhosting/Weblogicfiles',
    wls_user             => 'webadmin',
    wls_group            => 'webadmns',
    require              => Wls_plugins::Install['oam'],
  }

  file { '/home/webadmin/oraInst.loc':
    ensure  => file,
    owner   => 'webadmin',
    group   => 'webadmns',
    mode    => '0644',
    content => 'inventory_loc=/home/webadmin/oraInventory
    inst_group=webadmns',
  }

  file { '/opt/was/oracle/installers/idm/idmsuite-resp-oam.txt':
    ensure  => file,
    owner   => webadmin,
    group   => webadmns,
    mode    => '0640',
    content => template('wls_plugins/idmsuite-resp-oam.erb'),
    require => Wls_plugins::Extract['idm'],
  }

  exec { 'install IDM for OAM':
    cwd         => '/opt/was/oracle/installers/idm/Disk1',
    command     => "./runInstaller -jreLoc ${wls_java_home} -silent -ignoreSysPrereqs -response /opt/was/oracle/installers/idm/idmsuite-resp-oam.txt -invPtrLoc /home/webadmin/oraInst.loc",
    creates     => '/opt/was/oracle/oam/middleware/Oracle_IDM1/common/bin',
    path        => "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:${wls_java_home}/bin",
    environment => [ "JAVA_HOME=${wls_java_home}", ],
    user        => $wls_user,
    group       => $wls_group,
    logoutput   => true,
    require     => [
      Wls_plugins::Install['oam'],
      Wls_plugins::Extract['idm'],
      File['/opt/was/oracle/installers/idm/idmsuite-resp-oam.txt'],
    ],
  }
}
