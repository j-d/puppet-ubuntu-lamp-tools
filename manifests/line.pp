# Inspired by http://projects.puppetlabs.com/projects/puppet/wiki/Simple_Text_Patterns/5
define line(
    $file   = undef,
    $line   = undef,
    $ensure = 'present',
  ) {
  if $file == undef {
    fail('File not defined, please use file => \'/tmp/my_file.txt\'')
  }

  if $line == undef {
    fail('Line not defined, please use line => \'My sample line\'')
  }

  case $ensure {
    default : {
      fail ( "Unknown ensure value ${ensure}. Valid valus are \'present\' and \'absent\'" )
    }
    present: {
      exec { "/bin/echo '${line}' >> '${file}'":
        unless => "/bin/grep -qFx '${line}' '${file}'"
      }
    }
    absent: {
      exec { "/usr/bin/perl -ni -e 'print unless /^\\Q${line}\\E\$/' '${file}'":
        onlyif => "/bin/grep -qFx '${line}' '${file}'"
      }
    }
  }
}
