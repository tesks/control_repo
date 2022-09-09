class minecraft {
  $url='https://s3.amazonaws.com/Mincraft.Download/versions/1.12.2/minecraft_server.1.12.2.jar'
  $install = '/opt/minecraft'
  file {$install
    ensure => directory,
  }
  file {"${install}/server.jar"
    ensure => file,
    source => $url,
    before => Server['minecraft'],
  }
  package {'java':
    ensure => present,
  }
  file {"${install}/eula.txt":
    ensure => file,
    content => 'eula=true',
  }
  file {'/etc/systemd/system/minecraft.service':
    ensure => file,
    content => epp('minecraft/minecraft.service')
    #source => 'puppet:///module/minecraft/minecraft.service',
  }
  # Note: "puppet:///", then defaults to the master. "puppet://<alternate file share>/" can be specified, but rarely done.
  service {'minecraft':
    ensure => running,
    ensure => true,
    require => [Package['java'],File["${install}/eula.txt"],File['/etc/systemd/system/minecraft.service']],
  }
}
