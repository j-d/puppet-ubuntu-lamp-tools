class ubuntu_lamp_tools::vhost (
    $site_name   = undef,
    $server_name = undef,
  ) {
  if $site_name == undef {
    fail('Site name not defined, please use site_name => \'sample\'')
  }

  if $server_name == undef {
    fail('Server name not defined, please use server_name => \'sample.local\'')
  }

  file { "${site_name}.conf":
    ensure  => file,
    path    => "/etc/apache2/sites-available/${site_name}.conf",
    content => template('/vagrant/puppet/templates/vhost.conf.erb'),
    require => Package['apache2'],
    before  => [
      Exec["enable ${site_name}"],
      Line["hosts ${site_name}"],
    ],
    notify  => Service['apache2'],
  }

  line { "hosts ${site_name}":
    file => '/etc/hosts',
    line => "127.0.0.1 ${server_name}",
  }

  exec { "enable ${site_name}":
    command => "sudo a2ensite ${site_name}",
    creates => "/etc/apache2/sites-enabled/${site_name}.conf"
  }
}
