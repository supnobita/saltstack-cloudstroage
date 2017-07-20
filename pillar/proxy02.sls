swiftproxy:
    port: 8080
    name: proxy02
    statdhost: 10.0.0.61
    memcache: 127.0.0.1
    memcache_port: 11211
    ip: 10.0.0.250
    account_rep_port: 7002
    container_rep_port: 7001
    object_rep_port: 7000
    nodename: 02
    disks:
        - /dev/sdb
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
            - address: 10.0.0.250
              device: sdb
              zone: 1
              region: 1
              weight: 100
              account_port: 6002
              replication_ip: 10.0.10.250
            - address: 10.0.0.251
              device: sdb
              zone: 2
              region: 1
              replication_ip: 10.0.10.251
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