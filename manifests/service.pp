class openldap::service {
  service { $openldap::service:
    enable     => $openldap::enable,
    ensure     => $openldap::ensure,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => Class['openldap::config'],
  }
}
