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
  'roles:haproxy':
    - match: grain
    - haproxy
  'roles:keepalived_master':
    - match: grain
    - keepalived
  'roles:keepalived_slave':
    - match: grain
    - keepalived