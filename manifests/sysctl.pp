class wls_plugins::sysctl {

  Sysctl{
    ensure    => present,
    permanent => 'yes',
  }

  sysctl { 'kernel.msgmnb':                  value => '65536',}
  sysctl { 'kernel.msgmax':                  value => '65536',}
  sysctl { 'kernel.shmmax':                  value => '2588483584',}
  sysctl { 'kernel.shmall':                  value => '2097152',}
  sysctl { 'fs.file-max':                    value => '6815744',}
  sysctl { 'net.ipv4.tcp_keepalive_time':    value => '1800',}
  sysctl { 'net.ipv4.tcp_keepalive_intvl':   value => '30',}
  sysctl { 'net.ipv4.tcp_keepalive_probes':  value => '5',}
  sysctl { 'net.ipv4.tcp_fin_timeout':       value => '30',}
  sysctl { 'kernel.shmmni':                  value => '4096', }
  sysctl { 'fs.aio-max-nr':                  value => '1048576',}
  sysctl { 'kernel.sem':                     value => '250 32000 100 128',}
  sysctl { 'net.ipv4.ip_local_port_range':   value => '9000 65500',}
  sysctl { 'net.core.rmem_default':          value => '262144',}
  sysctl { 'net.core.rmem_max':              value => '4194304', }
  sysctl { 'net.core.wmem_default':          value => '262144',}
  sysctl { 'net.core.wmem_max':              value => '1048576',}
  sysctl { 'net.ipv6.conf.all.disable_ipv6':
    value => '1',
  } 
  sysctl { 'net.ipv6.conf.default.disable_ipv6':
    value => '1',
  }
  sysctl { 'net.ipv6.conf.lo.disable_ipv6':
    value => '1',
  }
}
