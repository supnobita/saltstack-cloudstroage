swiftproxy:
    port: 8080
    name: proxy01
    statdhost: 192.168.0.31
    memcache: 127.0.0.1
    memcache_port: 11211
    ip: 10.0.20.7
    object_rep_port: 7000
    nodename: 01
    disks:
        - /dev/vdb
    disk_prefix: /dev
#ring object must have default block is last block
    ring_builder:
      rings:
        - name: default
          container: true
          account: true
          partition_power: 9
          replicas: 2
          region: 1
          hours: 1
          devices:
            - address: 10.0.20.7
              device: vdb
              zone: 1
              region: 1
              weight: 200
              account_port: 6002
            - address: 10.0.20.6
              device: vdb
              zone: 1
              region: 1
              weight: 200
            - address: 10.0.20.5
              device: vdb
              zone: 1
              region: 1
              weight: 200
            - address: 10.0.20.4
              device: vdb
              zone: 1
              region: 1
              weight: 200
        - name: object
          object: True
          partition_power: 9
          replicas: 2
          hours: 1
          region: 1
          devices:
            - address: 10.0.0.250
              device: sdb
              zone: 1
              region: 1
              replication_ip: 10.0.10.250
            - address: 10.0.0.251
              device: sdb
              zone: 2
              region: 1
              replication_ip: 10.0.10.251









