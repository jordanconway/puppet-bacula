class puppetlabs::www {
  
  # Base
  include puppetlabs

  # Nagios
  include nagios::webservices
  include nagios::dbservices
  nagios::website { [ 'www.puppetlabs.com', 'docs.puppetlabs.com' ]: }

  # Munin
  include munin
  include munin::dbservices
  include munin::puppet

  # Collectd
  include collectd::client

  # Bacula
  $bacula_director = 'baal.puppetlabs.com'
  $bacula_password = 'MQI/vywQq5pSlAYaEUJKrmt24Wu8FOIPfT7tFoaOc5X6'
  include bacula

	# Training downloads
	file {
		"/var/www/puppetlabs.com/downloads":
			owner    => root,
			group    => release,
			mode     => 664,
			recurse  => true,
			checksum => none;
		"/var/www/puppetlabs.com/downloads/training/current-pm-vm.tar.gz":
			ensure => link,
			target => "centos-5.5-2.6.4.tar.gz";
		"/var/www/puppetlabs.com/downloads/training/current-pm-vm-ovf.tar.gz":
			ensure => link,
			target => "centos-5.5-2.6.4-ovf.tar.gz";
	}
		

  # Mysql
  $mysql_root_pw = 'afmesackjebhee'
  include mysql::server
  include postfix
  wordpress::instance {'puppetlabs.com':
    auth_key => 'PE{TEN%T).U~V6Cl;b_?0mcrvhoUVIP#+0R|e-LB>00:o*((b%[8pve/1Y+H}P(o',
    secure_auth_key => 'PDqD)bN|B22D.hxk@Uvy;nkT0#9QVB8=~J^r3@9f:7gRn9PmNGBth(t2+hLt|=Ne',
    logged_in_key => '#_Y3SS3oBj(<ja{dW+#fE!{=YhoiP<0@m~e)Gp[d0j5x1OxGAAFjl|3yHzmH{srZ',
    nonce_key => 'P,>pH-J+OTw#z2qn`M[lt||`[Nf|w#I:J %z>-MRY@Yt_Egyj84znb2H*s;0J||3',
    db_pw => 'gosh-if-no-hull',
    template => 'puppetlabs/puppetlabs_vhost.conf.erb',
  }
  package {'php5-curl': ensure => present, notify => Service[httpd] }
  realize(A2mod['headers'])
  realize(A2mod['expires'])
}
