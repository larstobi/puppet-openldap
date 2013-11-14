class openldap::config {
  file { '/var/lib/ldap/DB_CONFIG':
    ensure => present,
    source => $openldap::db_config,
    owner  => 'ldap',
    group  => 'ldap',
    mode   => '0600',
  }

  file { '/etc/rsyslog.d/slapd.conf':
    ensure => present,
    content => 'local4.* /var/log/slapd.log',
    notify  => Class['rsyslog::service'];
  }
}
