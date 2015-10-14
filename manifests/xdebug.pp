class ubuntu_lamp_tools::xdebug (
    $host_ip            = undef,
    $xdebug_remote_port = '9000',
    $xdebug_ide_key     = 'PHPSTORM',
  ) {
  if $host_ip == undef {
    fail('Host IP not defined, please use host_ip => \'192.168.0.1\'')
  }

  package {
    [
      'php5-xdebug',
    ]:
    ensure => 'latest'
  }

  # TODO: Improve this with something like multi-line

  line { 'php.ini apache xdebug remote_enable':
    file => '/etc/php5/apache2/php.ini',
    line => 'xdebug.remote_enable = On',
    require => Package['php5-xdebug'],
    notify  => Service['apache2'],
  }

  line { 'php.ini apache xdebug remote_host':
    file => '/etc/php5/apache2/php.ini',
    line => "xdebug.remote_host = ${host_ip}",
    require => Package['php5-xdebug'],
    notify  => Service['apache2'],
  }

  line { 'php.ini apache xdebug profiler_enable':
    file => '/etc/php5/apache2/php.ini',
    line => 'xdebug.profiler_enable = Off',
    require => Package['php5-xdebug'],
    notify  => Service['apache2'],
  }

  line { 'php.ini apache xdebug remote_port':
    file => '/etc/php5/apache2/php.ini',
    line => "xdebug.remote_port = ${xdebug_remote_port}",
    require => Package['php5-xdebug'],
    notify  => Service['apache2'],
  }

  line { 'php.ini apache xdebug idekey':
    file => '/etc/php5/apache2/php.ini',
    line => "xdebug.idekey = ${xdebug_ide_key}",
    require => Package['php5-xdebug'],
    notify  => Service['apache2'],
  }

  line { 'php.ini apache xdebug remote_log':
    file => '/etc/php5/apache2/php.ini',
    line => ';xdebug.remote_log = /var/www/xdebug.log',
    require => Package['php5-xdebug'],
    notify  => Service['apache2'],
  }

  line { 'php.ini cli xdebug remote_enable':
    file => '/etc/php5/cli/php.ini',
    line => 'xdebug.remote_enable = On',
    require => Package['php5-xdebug'],
    notify  => Service['apache2'],
  }

  line { 'php.ini cli xdebug remote_autostart':
    file => '/etc/php5/cli/php.ini',
    line => 'xdebug.remote_autostart = On',
    require => Package['php5-xdebug'],
    notify  => Service['apache2'],
  }

  line { 'php.ini cli xdebug remote_host':
    file => '/etc/php5/cli/php.ini',
    line => "xdebug.remote_host = ${host_ip}",
    require => Package['php5-xdebug'],
    notify  => Service['apache2'],
  }

  line { 'php.ini cli xdebug profiler_enable':
    file => '/etc/php5/cli/php.ini',
    line => 'xdebug.profiler_enable = Off',
    require => Package['php5-xdebug'],
    notify  => Service['apache2'],
  }

  line { 'php.ini cli xdebug remote_port':
    file => '/etc/php5/cli/php.ini',
    line => "xdebug.remote_port = ${xdebug_remote_port}",
    require => Package['php5-xdebug'],
    notify  => Service['apache2'],
  }

  line { 'php.ini cli xdebug idekey':
    file => '/etc/php5/cli/php.ini',
    line => "xdebug.idekey = ${xdebug_ide_key}",
    require => Package['php5-xdebug'],
    notify  => Service['apache2'],
  }

  line { 'php.ini cli xdebug remote_log':
    file => '/etc/php5/cli/php.ini',
    line => ';xdebug.remote_log = /var/www/xdebug.log',
    require => Package['php5-xdebug'],
    notify  => Service['apache2'],
  }
}
