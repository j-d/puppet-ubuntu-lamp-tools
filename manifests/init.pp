class ubuntu_lamp_tools (
  $mysql_password = 'password',
  $timezone       = 'Europe/London',
  $flags_folder   = '/.ubuntu_lamp_tools-flags'
) {
  Exec['apt-get update first run'] -> Exec['apt environmental variables'] -> Package <| |> -> Line <| |>

  file { $flags_folder:
    ensure => 'directory',
  }

  # Force to run apt-get the first time that the machine is provision
  file { "${flags_folder}/apt-get_first_run":
    ensure  => 'present',
    require => File[$flags_folder],
  }

  exec { 'apt-get update first run':
    command => 'apt-get update',
    creates => "${flags_folder}/apt-get_first_run",
    before  => File["${flags_folder}/apt-get_first_run"]
  }

  cron { 'apt-get update':
    command => '/usr/bin/apt-get update',
    special => 'reboot',
  }

  package {
    [
      'apache2',
      'php5',
      'php5-sqlite',
      'php5-apcu',
      'php5-curl',
      'php5-mysql',
      'php5-intl',
      'php5-mcrypt',
      'mysql-server',
      'phpmyadmin',
      'curl',           # Required to download composer
      'acl',            # Required to assign file permissions in Symfony
    ]:
    ensure => 'latest'
  }

  # Remove sample file created by apache installation
  file { '/var/www/html/index.html':
    ensure  => 'absent',
    require => Package['apache2'],
  }

  file { '/var/www/html':
    ensure  => 'absent',
    require => Package['apache2'],
    force   => 'yes',
  }

  service { 'apache2':
    enable     => 'true',
    ensure     => 'running',
    hasrestart => 'true',
    hasstatus  => 'true',
    require    => Package['apache2'],
  }

  line { 'php.ini cli timezone':
    file => '/etc/php5/cli/php.ini',
    line => "date.timezone =  ${timezone}",
  }

  line { 'php.ini apache timezone':
    file => '/etc/php5/apache2/php.ini',
    line => "date.timezone =  ${timezone}",
  }

  line { 'php.ini cli short open tag':
    file => '/etc/php5/cli/php.ini',
    line => 'short_open_tag = Off',
  }

  line { 'php.ini apache short open tag':
    file => '/etc/php5/apache2/php.ini',
    line => 'short_open_tag = Off',
  }

  exec { 'apt environmental variables':
    unless  => 'dpkg --get-selections | grep -v deinstall | grep phpmyadmin',
    command => "echo mysql-server mysql-server/root_password       password $mysql_password | debconf-set-selections;
                echo mysql-server mysql-server/root_password_again password $mysql_password | debconf-set-selections;
                echo phpmyadmin phpmyadmin/dbconfig-install        boolean true             | debconf-set-selections;
                echo phpmyadmin phpmyadmin/app-password-confirm    password $mysql_password | debconf-set-selections;
                echo phpmyadmin phpmyadmin/mysql/admin-pass        password $mysql_password | debconf-set-selections;
                echo phpmyadmin phpmyadmin/mysql/app-pass          password $mysql_password | debconf-set-selections;
                echo phpmyadmin phpmyadmin/reconfigure-webserver   multiselect apache2      | debconf-set-selections;",
  }

  exec { 'enable apache rewrite mod':
    command => 'a2enmod rewrite',
    require => Package['apache2'],
    notify  => Service['apache2'],
    unless  => 'apache2ctl -M | grep rewrite',
  }

  exec { 'enable mcrypt':
    command  => 'php5enmod mcrypt',
    require  => Package['apache2'],
    notify   => Service['apache2'],
    creates  => '/etc/php5/apache2/conf.d/20-mcrypt.ini',
  }

  exec { "disable 000-default":
    command => "sudo a2dissite 000-default",
    require => Package['apache2'],
    notify  => Service['apache2'],
    unless  => 'test ! -f /etc/apache2/sites-enabled/000-default.conf'
  }

  exec { 'composer':
    cwd     => '/tmp',
    command => '/vagrant/puppet/modules/ubuntu_lamp_tools/shell/composer.sh', #TODO: Replace with dynamic path
    creates => '/usr/local/bin/composer',
    require => [
      Package['php5'],
      Package['curl'],
    ],
  }

  # Change the system time
  file { '/etc/timezone':
    ensure  => 'file',
    path    => '/etc/timezone',
    content => "${timezone}\n",
    require => Package['apache2'],
    notify  => [
      Service['apache2'],
      Exec['dpkg-reconfigure-tzdata'],
    ],
  }

  exec { 'dpkg-reconfigure-tzdata':
    command     => 'dpkg-reconfigure --frontend noninteractive tzdata',
    refreshonly => true,
  }
}
