define openldap::schema (
  $source = $title,
  $schema_dir = hiera('openldap::schema_dir', '/etc/ldap/schema'),
  ) {
  case $source {
    /([A-Za-z0-9\-_]+\.schema)/: { $schema_file = $1 }
    default: { notify { 'Could not match openldap schema file.': } }
  }

  file {
    $schema_file:
      ensure => present,
      path   => "${schema_dir}/${schema_file}",
      source => $source,
  }
}
