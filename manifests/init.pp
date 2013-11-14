# == Class: openldap
#
# Manages OpenLDAP.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { openldap:
#    ldap_conf => 'puppet:///modules/mycompany/ldap.conf',
#  }
#
# === Authors
#
# Lars Tobias Skjong-Borsting <larstobi@conduct.no>
#
# === Copyright
#
# Copyright 2013 Lars Tobias Skjong-Borsting <larstobi@conduct.no>
#
class openldap (
  $packages   = hiera('openldap::packages', ['openldap-servers', 'openldap-clients']),
  $ensure     = hiera('openldap::ensure',    'running'),
  $enable     = hiera('openldap::enable',    'true'),
  $service    = hiera('openldap::service',   'slapd'),
  $ldap_conf  = hiera('openldap::ldap_conf', 'puppet:///modules/openldap/ldap.conf'),
  $slapd_conf = hiera('openldap::slapd_conf', undef),
  $db_config  = hiera('openldap::db_config',  undef),
  $logdir     = hiera('openldap::logdir',    '/var/log/openldap'),
  $logfile    = hiera('openldap::logfile',   '/var/log/openldap/slapd.log'),
  $schema     = hiera_array('openldap::schema', undef),
  ) {
  include openldap::packages
  include openldap::config
  include openldap::service
  include openldap::firewall
  include openldap::replication
  Class['openldap::packages'] -> Class['openldap::config']
  Class['openldap::config']   -> Class['openldap::service']
  Class['openldap::service']   -> Class['openldap::firewall']
  Class['openldap::firewall']  -> Class['openldap::replication']
}
