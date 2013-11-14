class openldap::packages {
  $packages = $openldap::packages

  package { $packages:
    ensure => installed,
  }
}
