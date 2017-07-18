#top for pillar

base:
  '*':
    - common
  'roles:webserver':
    - match: grain
    - webserver
    - glusterfs_p
    - keepalived_cluster
  'roles:glusterfs':
    - match: grain
    - glusterfs_p
  'roles:swiftproxy01':
    - match: grain
    - proxy01
  'roles:keepalived_master':
    - match: grain
    - keepalived_master
  'roles:keepalived_slave':
    - match: grain
    - keepalived_slave
  'roles:swiftobject01':
    - match: grain
    - proxy01
  'roles:swiftobject02':
    - match: grain
    - proxy02
  'roles:swiftproxy02':
    - match: grain
    - proxy02