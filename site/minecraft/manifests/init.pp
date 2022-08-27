class minecraft {
  file {'/opt/minecraft'
    ensure => directory,
  }
  file {'/opt/minecraft/server.jar'
    ensure => file,
    source => 
  }
}
