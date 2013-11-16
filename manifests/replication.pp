class openldap::replication (
  $serverid    = hiera('openldap::serverid',   undef),
  $serverurls  = hiera('openldap::serverurls', undef),
  $rootdn      = hiera('openldap::rootdn',     undef),
  $rootpw      = hiera('openldap::rootpw',     undef),
  $suffix      = hiera('openldap::suffix',     undef),
  $olcloglevel = hiera('openldap::loglevel',   'stats'),
  ) {
  $base        = '-b "cn=config" -D "cn=admin,cn=config"'
  $ldapsearch  = "/usr/bin/ldapsearch -Y EXTERNAL -H ldapi:/// -LLL -Q ${base}"
  $ldapadd     = '/usr/bin/ldapadd -Y EXTERNAL -H ldapi:///'
  $syncprov    = template('openldap/syncprov.ldif.erb')
  $rootdn_ldif = template('openldap/rootdn.ldif.erb')
  $config_rootpw_ldif = template('openldap/config_rootpw.ldif.erb')
  $data_rootpw_ldif = template('openldap/data_rootpw.ldif.erb')

  $data_access_ldif        = template('openldap/data_access.ldif.erb')
  $config_serverid_ldif    = template('openldap/config_serverid.ldif.erb')
  $config_repl_ldif        = template('openldap/config_replication.ldif.erb')
  $data_serverid_ldif      = template('openldap/data_serverid.ldif.erb')
  $data_repl_ldif          = template('openldap/data_replication.ldif.erb')
  $data_ppolicy_ldif       = template('openldap/data_ppolicy.ldif.erb')
  $mod_ppolicy             = template('openldap/mod_ppolicy.ldif.erb')
  $mod_memberof            = template('openldap/mod_memberof.ldif.erb')
  $data_memberof           = template('openldap/data_memberof.ldif.erb')
  $config_loglevel_ldif    = template('openldap/loglevel.ldif.erb')
  $acl_bdb_external        = template('openldap/acl_bdb_external.ldif.erb')

  Exec{ path => '/usr/bin:/bin' }

  exec {
    'include ppolicy module':
      command => "${ldapadd} -D 'cn=admin,cn=config'<<EOF${mod_ppolicy}EOF",
      unless  => "${ldapsearch} ObjectClass=olcModuleList olcModuleLoad | grep '^olcModuleLoad:.*ppolicy.la$'";
  }
  ->
  exec {
    'include syncrepl module':
      command => "${ldapadd} -D 'cn=admin,cn=config'<<EOF${syncprov}EOF",
      unless  => "${ldapsearch} ObjectClass=olcModuleList olcModuleLoad | grep '^olcModuleLoad:.*syncprov.la$'";
  }
  ->
  exec {
    'change rootdn':
      command => "${ldapadd} -D 'cn=admin,cn=config'<<EOF${rootdn_ldif}EOF",
      unless  => "${ldapsearch} olcDatabase={2}bdb olcRootDN | grep '^olcRootDN:\\ '|grep \"${rootdn}\"";
  }
  ->
  exec {
    'add config olcRootPW':
      command => "${ldapadd} -D 'cn=admin,cn=config'<<EOF${config_rootpw_ldif}EOF",
      unless  => "${ldapsearch} olcDatabase={0}config olcRootPW | grep '^olcRootPW:\\ '";
  }
  ->
  exec {
    'add data olcRootPW':
      command => "${ldapadd} -D 'cn=admin,cn=config'<<EOF${data_rootpw_ldif}EOF",
      unless  => "${ldapsearch} olcDatabase={2}bdb olcRootPW | grep '^olcRootPW:\\ '";
  }
  ->
  # exec {
  #   'add_acl_bdb_external':
  #     command => "${ldapadd} -D 'cn=admin,cn=config'<<EOF${acl_bdb_external}EOF",
  #     unless  => "${ldapsearch} olcDatabase={2}bdb olcAccess | perl -p00e 's/\\r?\\n //g' | grep '^olcAccess:\\ ' | grep 'cn=peercred,cn=external'";
  # }
  # ->
  exec {
    'add_loglevel':
      command => "${ldapadd} -D 'cn=admin,cn=config'<<EOF${config_loglevel_ldif}EOF",
      unless  => "${ldapsearch} cn=config olcLogLevel | grep '^olcLogLevel:\\ '";
  }
  ->
  exec {
    'config_serverid':
      command => "${ldapadd} -D 'cn=admin,cn=config'<<EOF${config_serverid_ldif}EOF",
      unless  => "${ldapsearch} cn=config olcServerID | grep '^olcServerID:\\ '";
  }
  ->
  exec {
    'add config replication':
      command => "${ldapadd} -D 'cn=admin,cn=config'<<EOF${config_repl_ldif}EOF",
      unless  => "${ldapsearch} olcDatabase={0}config olcSyncrepl | grep '^olcSyncrepl:\\ '";
  }
  ->
  exec {
    'sleep 5':
  }
  ->
  exec {
    'add data access':
      command => "${ldapadd} -D 'cn=admin,cn=config'<<EOF${data_access_ldif}EOF",
      unless  => "${ldapsearch} olcDatabase={2}bdb olcAccess | perl -p00e 's/\\r?\\n //g' | grep 'dn.exact=\"${rootdn}\"'";
  }
  ->
  exec {
    'add data replication':
      command => "${ldapadd} -D 'cn=admin,cn=config'<<EOF${data_repl_ldif}EOF",
      unless  => "${ldapsearch} olcDatabase={2}bdb olcSyncrepl | perl -p00e 's/\\r?\\n //g' | grep '^olcSyncrepl:\\ ' | grep 'searchbase=\"${suffix}\"'";
  }
  ->
  exec {
    'sleep 4':
  }
  ->
  exec {
    'add data ppolicy':
      command => "${ldapadd} -D 'cn=admin,cn=config'<<EOF${data_ppolicy_ldif}EOF",
      unless  => "${ldapsearch} 'olcOverlay={1}ppolicy' olcPPolicyDefault |grep '^olcPPolicyDefault:\\ '";
  }
  ->
  exec {
    'include memberof module':
      command => "${ldapadd} -D 'cn=admin,cn=config'<<EOF${mod_memberof}EOF",
      unless  => "${ldapsearch} ObjectClass=olcModuleList olcModuleLoad | grep '^olcModuleLoad:.*memberof.la$'";
  }
  ->
  exec {
    'add data memberof':
      command => "${ldapadd} -D 'cn=admin,cn=config'<<EOF${data_memberof}EOF",
      unless  => "${ldapsearch} olcOverlay=memberof olcMemberOfRefInt | grep ^olcMemberOfRefInt:";
  }
}
