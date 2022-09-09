class minecraft {
  file {'/opt/minecraft'
    ensure => directory,
  }
  file {'/opt/minecraft/server.jar'
    ensure => file,
    source => 'https://s3.amazonaws.com/Mincraft.Download/versions/1.12.2/minecraft_server.1.12.2.jar',
  }
  package {'java':
    ensure => present,
  }
  file {'/opt/minecraft/eula.txt':
    ensure => file,
    content => 'eula=true',
  }
  file {'/etc/systemd/system/minecraft.service':
    ensure => file,
    source => 'puppet:///module/minecraft/minecraft.service',
  }
  # Note: "puppet:///", then defaults to the master. "puppet://<alternate file share>/" can be specified, but rarely done.
}
