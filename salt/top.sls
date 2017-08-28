#top.sls

base:
  '*':
    - ntp
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
    - swift_proxy
  'roles:swiftproxy02':
    - match: grain
    - swift_proxy
  'roles:swiftproxy03':
    - match: grain
    - swift_proxy
  'roles:swiftproxy04':
    - match: grain
    - swift_proxy
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
  'roles:swiftobject01':
    - match: grain
    - swift_object
  'roles:swiftobject02':
    - match: grain
    - swift_object