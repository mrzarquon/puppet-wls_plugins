class wls_plugins::examples::ovd (
  $wls_user = 'webadmin',
  $wls_group = 'webadmns',
  $wls_java = 'jdk1.7.0_72',
  $wls_java_dir = '/opt/product/java',
  $wls_middleware_home = '/opt/was/oracle/ovd/middleware',
  $wls_install_dir = "/opt/was/oracle/ovd/middleware/wlserver_10.3",
  $wls_oracle_idm_home = "/opt/was/oracle/ovd/middleware/Oracle_IDM1",
  $wls_domain_hostname = $::fqdn,
  $wls_domain_name = 'IDMDomain',
  $wls_domain_user = 'weblogic',
  $wls_domain_pass = 'weblogic01',
  $wls_oracle_home = '/opt/was/oracle/ovd/middleware/Oracle_IDM',
  $wls_instance_home = '/opt/was/oracle/ovd/middleware/OVD_Instance',
  $wls_instance_name = 'OVD_Instance',
  $wls_ovd_pass = 'weblogic01',
  $wls_ovd_ldap_namespace = 'dc=lfg,dc=com',
  $wls_ovd_ldap_admin = 'cn=orcladmin',
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

  file { '/usr/java':
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0644',
  }
  
  file { '/usr/java/latest':
    ensure  => link,
    target  => $wls_java_home,
    require => Wls_plugins::Java['jdk1.7.0_72'],
  }

  file { '/opt/was/oracle/installers/silent_weblogic_install_ovd.xml':
    ensure  => file,
    owner   => $wls_user,
    group   => $wls_group,
    mode    => '0640',
    content => template('wls_plugins/silent_weblogic_install_ovd.erb'),
    require => File['/opt/was/oracle/installers'],
  }
  
  wls_plugins::install { 'ovd': 
    wls_java          => 'jdk1.7.0_72',
    wls_java_dir      => '/opt/product/java/',
    wls_plugin_dir    => '/opt/was/oracle/ovd',
    wls_installer     => '/opt/was/oracle/installers/wls1036_generic.jar',
    wls_installer_dir => '/opt/was/oracle/installers',
    wls_logs          => '/opt/was/oracle/installers/logs/weblogic_install_oam.log',
    wls_answers       => '/opt/was/oracle/installers/silent_weblogic_install_ovd.xml',
    wls_user          => 'webadmin',
    wls_group         => 'webadmns',
    require           => File['/opt/was/oracle/installers/silent_weblogic_install_ovd.xml'],
  }

  wls_plugins::extract { 'ovd':
    wls_zip_1            => 'ofm_idm_linux_11.1.1.7.0_64_disk1_1of1.zip',
    wls_installer_dir    => '/opt/was/oracle/installers',
    wls_installer_source => '/tmp/webhosting/Weblogicfiles',
    wls_user             => 'webadmin',
    wls_group            => 'webadmns',
    require              => Wls_plugins::Install['ovd'],
  }

  file { '/home/webadmin/oraInst.loc':
    ensure  => file,
    owner   => 'webadmin',
    group   => 'webadmns',
    mode    => '0644',
    content => 'inventory_loc=/home/webadmin/oraInventory
inst_group=webadmns',
  }

  file { '/opt/was/oracle/installers/ovd/ovd_silent_install.txt':
    ensure  => file,
    owner   => webadmin,
    group   => webadmns,
    mode    => '0640',
    content => template('wls_plugins/ovd_silent_install.erb'),
    require => Wls_plugins::Extract['ovd'],
  }

  $wls_runinstaller_location = '/opt/was/oracle/installers/ovd/Disk1/runInstaller'
  $wls_runinstaller_answers = '/opt/was/oracle/installers/ovd/ovd_silent_install.txt'
  
  #file { '/home/webadmin/installer.sh':
  #  ensure  => file,
  #  owner   => $wls_user,
  #  mode    => '0644',
  #  content => template('wls_plugins/install_runner.erb'),
  #}


  exec { 'install OVD for IDM':
    cwd         => '/opt/was/oracle/installers/ovd/Disk1',
    command     => template('wls_plugins/install_runner.erb'),
    creates     => '/opt/was/oracle/ovd/middleware/user_projects/domains/IDMDomain/servers/AdminServer/security',
    path        => "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:${wls_java_home}/bin",
    environment => [ "JAVA_HOME=${wls_java_home}", ],
    user        => $wls_user,
    group       => $wls_group,
    logoutput   => true,
    require     => [
      Wls_plugins::Install['ovd'],
      Wls_plugins::Extract['ovd'],
      File['/opt/was/oracle/installers/ovd/ovd_silent_install.txt'],
    ],
  }


}
