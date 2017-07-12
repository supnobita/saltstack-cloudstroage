#top.sls

base:
  'roles:webserver':
    - match: grain
    - nginxserver
  'roles:dbmaster':
    - match: grain
    - galera
  'roles:dbslave*':
    - match: grain
    - galera
  'roles:glusterfs':
    - match: grain
    - glusterfs
  'roles:proftpd':
    - match: grain
    - proftpd
  'roles:swiftproxy01':
    - match: grain
    - keystone
    - keystone-endpoint
  'roles:keepalived_master':
    - match: grain
    - keepalived
  'roles:keepalived_slave':
    - match: grain
    - keepalived
  'roles:haproxy':
    - match: grain
    - haproxy
  'roles:keystone':
    - match: grain
    - keystone
    - keystone-endpoint
#keystone1 - dont rerun endpoint state file
  'roles:keystone1':
    - match: grain
    - keystone