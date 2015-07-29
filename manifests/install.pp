define wls_plugins::install(
  $wls_plugin = $name,
  $wls_java = 'jdk1.7.0_72',
  $wls_java_dir = '/opt/product/java/',
  $wls_plugin_dir = "/opt/was/oracle/${wls_plugin}",
  $wls_installer = '/opt/was/oracle/installers/wls1036_generic.jar',
  $wls_installer_dir = '/opt/was/oracle/installers',
  $wls_logs = "${wls_installer_dir}/logs/weblogic_install_${name}.log",
  $wls_answers = "/opt/was/oracle/installers/silent_weblogic_install_${wls_plugin}.xml",
  $wls_user = 'webadmin',
  $wls_group = 'webadmns',
) {

  $wls_java_home = "${wls_java_dir}/${wls_java}"
  $wls_java_bin = "${wls_java_home}/bin/java"

  file { "/opt/was/oracle/${wls_plugin}":
    ensure => directory,
    owner  => $wls_user,
    group  => $wls_group,
  }

  #exec { "${wls_plugin}-plugin-install":
  #  command     => "${wls_java_bin} -d64 -jar ${wls_installer} -mode=silent -silent_xml=${wls_answers} log=${wls_logs}",
  #  creates     => "${wls_plugin_dir}/middleware",
  #  environment => [ "JAVA_HOME=${wls_java_home}", ],
  #  path        => "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:${wls_java_home}/bin",
  #  logoutput   => true,
  #  user        => $wls_user,
  #  group       => $wls_group,
  #}

}
