# Copyright 2009 Larry Ludwig (larrylud@gmail.com)
#
# Licensed under the Apache License, Version 2.0 (the "License"); you 
# may not use this file except in compliance with the License. You 
# may obtain a copy of the License at 
#
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, 
# software distributed under the License is distributed on an "AS IS"
# BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express 
# or implied. See the License for the specific language governing 
# permissions and limitations under the License. 
#
# installs mysql 
class mysql::server {
  # set the mysql root password
  if(! $mysql_rootpw) {
    fail('$mysql_rootpw must be set for class mysql::server')
  }
  package{'mysql-server':
    name   => 'MySQL-server-community',
    ensure => installed,
    notify => Service['mysql'],
  }
  service { 'mysql':
    ensure => running,
    enable => true,
    subscribe => File['/etc/my.cnf'],
  }
  File{
    owner   => 'mysql',
    group   => 'mysql',
    require => Package['mysql-server'],
  }
  # what is this for??
  file{'/var/lib/mysql/data':
    ensure => directory,
    mode   => 755,
    before => File['/usr/local/sbin/setmysqlpass.sh'],
  }
  # what is this for??
  file{'/var/lib/mysql/data/ibdata1':
    ensure => file,
    mode   => 0660,
    before => File['/usr/local/sbin/setmysqlpass.sh'],
  }  
  # does this need to be a script?
  file{ '/usr/local/sbin/setmysqlpass.sh':
    mode   => 0500,
    source => 'puppet:///modules/mysql/setmysqlpass.sh',
  }
  exec{ 'set_mysql_rootpw':
    command   => "setmysqlpass.sh ${mysql_rootpw}",
    #logoutput => on_failure,
    logoutput => true,
    unless   => "mysqladmin -uroot -p${mysql_rootpw} status > /dev/null",
    path      => '/usr/local/sbin:/usr/bin',
    require   => [File['/usr/local/sbin/setmysqlpass.sh'], Package['mysql-server']],
    before    => File['/root/.my.cnf'],
    notify    => Service['mysql'],
  } 

  file{'/etc/my.cnf':
    ensure => file,
  }
 
  file{'/root/.my.cnf':
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => template('mysql/my.cnf.erb'),
    notify  => Service['mysql'],
  }

  # install monitoring username if nrpe or snmp is enabled
  # does this actually work
  include mysql::server::mysqltuner
  if tagged(nrpe) {
    include mysql::server::monitor
  }
  if tagged(cacti) {
    include mysql::server::monitor
  }
}
