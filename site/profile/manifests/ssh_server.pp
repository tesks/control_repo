class profile::ssh_server {
    package {
        'openssh-server':
            ensure => present,
    }
    service { 'sshd':
        ensure => 'running',
        enable => 'true',
    }
    ssh_authorized_key {'root@master.puppet.vm':
        ensure => present,
        user => 'root',
        type => 'ssh-rsa',
        key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC04CzqfvMAexv/O6K3I8ddL/7xbsCEMwEJXKoc5Sbpk15vUCWRQMic5o0rKg0ki07K4inoQEl6DfyMN7VA7wrE2BJDtPQLgdnDMZfeYggMJ2Ro8/3U4mN65XGA0SEdJB9n/y/JZ4yEbvWSpnYarZ8rXeOmRHRuPhXXPkUFQoTciek9zrOu9wt+VTNlo/se7eT/+1XKN6Kv4jUEL0bB098Dn0DKqFl2u/5kMC0IC4f4OkNN4dtCLg1yU4OsZD06TLzGDGUg9Egvw2M9/EvsKUzjiAvIalUI5oyrwOnZo0QHjC6qz1DesH+VySxAPdF48vuYiChim5WLyIkWeFuVGVP5',
    }
}
