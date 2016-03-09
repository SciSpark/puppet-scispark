define scispark::anaconda_install($script=$title, $install_dir, $owner, $group, $creates) {

  # create the install directory
  file { "$install_dir":
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => 0755,
  }

  # cat the shell script parts
  exec { "cat $script.*":
    creates => "/tmp/$script",
    path    => ["/bin", "/usr/bin"],
    command => "cat /etc/puppet/modules/scispark/files/$script.* > /tmp/$script",
    notify  => Exec["chmod $script"],
  }

  # chmod the shell script
  exec { "chmod $script":
    path    => ["/bin", "/usr/bin"],
    command => "chmod 755 /tmp/$script",
    notify  => Exec["run $script"],
  }

  # install anaconda at the desired location
  exec { "run $script":
    creates     => $creates,
    path        => ["/bin", "/usr/bin", "/usr/sbin", "/sbin"],
    command     => "/tmp/$script -b -f -p $install_dir",
    refreshonly => true,
    require     => [ Exec["chmod $script"], File["$install_dir"] ]
  }
}
