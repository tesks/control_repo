# Install Java 8 (JDK)
package { 'openjdk-8-jdk':
  ensure => installed,
}

# Install wget
package { 'wget':
  ensure => installed,
}

# Set JAVA_HOME and PATH in user's ~/.bash_profile
file { '/home/user/.bash_profile':
  ensure  => present,
  content => "export JAVA_HOME=/opt/java/openjdk-1.8\nexport PATH=$PATH:$HOME/bin:$JAVA_HOME/bin\n",
}

# Source ~/.bash_profile
exec { 'source_bash_profile':
  command     => 'source /home/user/.bash_profile',
  refreshonly => true,
  require     => File['/home/user/.bash_profile'],
}

# Let the operating system know where Java is and which version to use
exec { 'update_java_alternatives':
  command => "sudo update-alternatives --install \"/usr/bin/java\" \"java\" \"/opt/java/openjdk-1.8/bin/java\" 1 && \
              sudo update-alternatives --install \"/usr/bin/javac\" \"javac\" \"/opt/java/openjdk-1.8/bin/javac\" 1 && \
              sudo update-alternatives --install \"/usr/bin/java\" \"javaws\" \"/opt/java/openjdk-1.8/bin/javaws\" 1 && \
              sudo update-alternatives --set java /opt/java/openjdk-1.8/bin/java && \
              sudo update-alternatives --set javac /opt/java/openjdk-1.8/bin/javac && \
              sudo update-alternatives --set javaws /opt/java/openjdk-1.8/bin/javaws",
}

# Install ActiveMQ
file { '/opt/activemq':
  ensure => directory,
}

exec { 'download_activemq':
  command => 'sudo wget https://archive.apache.org/dist/activemq/5.16.1/apache-activemq-5.16.1-bin.tar.gz && \
              sudo tar zxvf apache-activemq-5.16.1-bin.tar.gz',
  cwd     => '/opt/activemq',
  creates => '/opt/activemq/apache-activemq-5.16.1',
}

# Start ActiveMQ
exec { 'start_activemq':
  command => './activemq start',
  cwd     => '/opt/activemq/apache-activemq-5.16.1/bin',
  require => Exec['download_activemq'],
}

# Install Python 3.9+
package { 'python3.9':
  ensure => installed,
}

# Install git
package { 'git':
  ensure => installed,
}

# Clone AMPCS repository
exec { 'clone_ampcs_repository':
  # command => 'git clone https://github.com/NASA-AMMOS/AMPCS.git',
  command => 'git clone https://github.com/tesks/mock-os-deleteme.git',
  cwd     => '/home/user',
}

# Install other auxiliary tools
package { 'nc':
  ensure => installed,
}

package { 'telnet':
  ensure => installed,
}

package { 'net-tools':
  ensure => installed,
}

# Install Maven 3.6.3
file { '/opt/maven':
  ensure => directory,
}

exec { 'download_maven':
  command => 'sudo wget https://archive.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz && \
              sudo tar zxvf apache-maven-3.6.3-bin.tar.gz && \
              sudo ln -s apache-maven-3.6.3 maven',
  cwd     => '/opt/maven',
  creates => '/opt/maven/apache-maven-3.6.3',
}

# Add M2_HOME and PATH to ~/.bash_profile
file { '/home/user/.bash_profile':
  ensure  => present,
  content => "export M2_HOME=/opt/maven/maven\nexport PATH=${M2_HOME}/bin:${PATH}\n",
}

# Source ~/.bash_profile
exec { 'source_bash_profile_maven':
  command     => 'source /home/user/.bash_profile',
  refreshonly => true,
  require     => File['/home/user/.bash_profile'],
}

# Install MariaDB
package { 'mariadb-server':
  ensure => installed,
}

# Build AMPCS
exec { 'build_ampcs':
  command => 'mvn -DskipTests -DskipPythonTests clean install',
  cwd     => '/home/user/AMPCS',
  require => Exec['clone_ampcs_repository'],
}

# Run clean_test_jars.sh script
exec { 'clean_test_jars':
  command => 'dev_scripts/bash/clean_test_jars.sh ~/AMPCS',
  cwd     => '/home/user/AMPCS',
  require => Exec['build_ampcs'],
}

# Add environment variables to ~/.bash_profile
file { '/home/user/.bash_profile':
  ensure  => present,
  content => "export ACTIVEMQ_HOME=/opt/activemq/apache-activemq-5.16.1\nexport PATH=$ACTIVEMQ_HOME/bin:$PATH\nexport AMPCS_WORKSPACE_ROOT=~/AMPCS\nexport CHILL_GDS=${AMPCS_WORKSPACE_ROOT}/adaptations/generic/dist/generic\n",
}

# Source ~/.bash_profile
exec { 'source_bash_profile_ampcs':
  command     => 'source /home/user/.bash_profile',
  refreshonly => true,
  require     => File['/home/user/.bash_profile'],
}

# Install Python modules
package { 'python3-pip':
  ensure => installed,
}

exec { 'install_python_modules':
  command => 'pip3 install -r $CHILL_GDS/lib/python/ampcs_requirements.txt',
  environment => ['CHILL_GDS=/home/user/AMPCS/adaptations/generic/dist/generic'],
  require => [Exec['source_bash_profile_ampcs'], Package['python3-pip']],
}

# Create mission database
exec { 'create_mission_database':
  command => "$CHILL_GDS/bin/admin/chill_grant_mission_permissions -u root -p",
  environment => ['CHILL_GDS=/home/user/AMPCS/adaptations/generic/dist/generic'],
  require => Exec['install_python_modules'],
}

# Create unit test database
exec { 'create_unit_test_database':
  command => "$CHILL_GDS/bin/admin/chill_grant_unit_test_permissions -u root -p && \
              $CHILL_GDS/bin/admin/chill_create_unit_test_database -u root -p",
  environment => ['CHILL_GDS=/home/user/AMPCS/adaptations/generic/dist/generic'],
  require => Exec['create_mission_database'],
}
