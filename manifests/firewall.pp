class openldap::firewall {
  firewall { '100 allow ldap and ldaps access':
    port   => [389, 636],
    proto  => ['tcp', 'udp'],
    action => accept,
  }
}
