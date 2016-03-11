#####################################################
# scispark class
#####################################################

class scispark {

  #####################################################
  # create groups and users
  #####################################################
  $user = 'sdeploy'
  $group = 'sdeploy'

  group { $group:
    ensure     => present,
  }

  user { $user:
    ensure     => present,
    gid        => $group,
    shell      => '/bin/bash',
    home       => "/home/$user",
    managehome => true,
    require    => Group[$group],
  }


  file { "/home/$user":
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => 0755,
    require => User[$user],
  }


  file { "/etc/sudoers.d/90-cloudimg-$user":
    ensure  => file,
    content  => template('scispark/90-cloudimg-user'),
    mode    => 0440,
    require => [
                User[$user],
               ],
  }


  #####################################################
  # add .inputrc to users' home
  #####################################################

  inputrc { 'root':
    home => '/root',
  }
  
  inputrc { $user:
    home    => "/home/$user",
    require => User[$user],
  }


  #####################################################
  # change default user
  #####################################################

  file_line { "default_user":
    ensure  => present,
    line    => "    name: $user",
    path    => "/etc/cloud/cloud.cfg",
    match   => "^    name:",
    require => User[$user],
  }


  #####################################################
  # install .bashrc
  #####################################################

  file { "/home/$user/.bashrc":
    ensure  => present,
    content => template('scispark/bashrc'),
    owner   => $user,
    group   => $group,
    mode    => 0644,
    require => User[$user],
  }


  file { "/root/.bashrc":
    ensure  => present,
    content => template('scispark/bashrc'),
    mode    => 0600,
  }


  #####################################################
  # install packages
  #####################################################


  #####################################################
  # refresh ld cache
  #####################################################

  if ! defined(Exec['ldconfig']) {
    exec { 'ldconfig':
      command     => '/sbin/ldconfig',
      refreshonly => true,
    }
  }
  

  #####################################################
  # install anaconda
  #####################################################

  anaconda_install { "Anaconda2-2.5.0-Linux-x86_64.sh":
    install_dir => "/home/$user/anaconda",
    creates     => "/home/$user/anaconda/bin/python",
    owner       => $user,
    group       => $group,
    require     => User[$user],
  }

}
