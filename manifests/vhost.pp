class ubuntu_lamp_tools::vhost (
    $site_name            = undef,
    $server_name          = undef,
    $web_folder           = '/web',
    $ports                = ['80', '8080'],
    $server_alias         = '',
    $server_document_root = '/var/www',
    $directory_index      = 'app.php'
  ) {
  $server_document_root = "${server_document_root}${web_folder}"
  
  if $site_name == undef {
    fail('Site name not defined, please use site_name => \'sample\'')
  }

  if $server_name == undef {
    fail('Server name not defined, please use server_name => \'sample.local\'')
  }

  file { "${site_name}.conf":
    ensure  => 'file',
    path    => "/etc/apache2/sites-available/${site_name}.conf",
    content => template('/vagrant/puppet/modules/ubuntu_lamp_tools/templates/vhost.conf.erb'), #TODO: Replace with dynamic path
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

  define apache_port { # foreach workaround
    line { "ports.conf ${name}":
      file => '/etc/apache2/ports.conf',
      line => "Listen ${name}",
      require => Package['apache2'],
      notify  => Service['apache2'],
    }
  }

  apache_port { $ports: }
}
