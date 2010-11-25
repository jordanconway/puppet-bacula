class virtual::groups {
  @group {'sysadmin':
    ensure => present,
    gid => 666,
  }
  @group {'developers':
    ensure => present,
    gid => 667,
  }
  @group {'prosvc':
    ensure => present,
    gid => 668,
  }
  @group {'hudson':
    ensure => present,
    gid => 669,
  }
}
