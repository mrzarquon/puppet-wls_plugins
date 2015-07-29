define wls_plugins::java (
  $wls_java = $name,
  $wls_java_dir = '/opt/product/java/',
  $wls_java_installer,
) {

  $wls_java_home = "${wls_java_dir}/${wls_java}"
  $wls_java_bin = "${wls_java_home}/bin/java"

  exec { "install ${wls_java} in ":
    cwd       => $wls_java_dir,
    command   => "tar -xzf ${wls_java_installer}",
    creates   => $wls_java_bin,
    path      => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:',
    logoutput => true,
    user      => 'root',
  }
}
