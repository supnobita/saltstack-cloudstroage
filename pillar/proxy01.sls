swiftproxy:
    port: 8080
    name: proxy01
    statdhost: 10.0.0.61
    memcache: 10.0.0.82
    memcache_port: 22121
    ip: 10.0.0.201
    nodename: 01
    disks:
        - /dev/sdb
        - /dev/sdc
    disk_prefix: /dev
#ring object must have default block is last block
    ring_builder:
      rings:
        - name: default
          container: true
          account: true
          partition_power: 9
          replicas: 3
          region: 1
          hours: 1
          devices:
            - address: 10.0.0.201
              device: sdb
              zone: 1
              region: 1
              weight: 100
              account_port: 6000
            - address: 10.0.0.202
              device: sdc
              zone: 2
              region: 1
        - name: object
          object: True
          partition_power: 9
          replicas: 3
          hours: 1
          region: 1
          devices:
            - address: 10.0.0.201
              device: sdb
              zone: 1
              region: 1
            - address: 10.0.0.202
              device: sdc
              zone: 2
              region: 1