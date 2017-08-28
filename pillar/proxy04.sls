swiftproxy:
    port: 8080
    name: proxy04
    statdhost: 192.168.0.31
    memcache: 127.0.0.1
    memcache_port: 11211
    ip: 10.0.20.4
    nodename: 04
    object_rep_port: 7000
    disks:
        - /dev/vdb
    disk_prefix: /dev
#ring object must have default block is last block
    ring_builder:
      rings:
        - name: default
          container: true
          account: true
          partition_power: 14
          replicas: 3
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
              zone: 2
              region: 1
              weight: 200
            - address: 10.0.20.4
              device: vdb
              zone: 2
              region: 1
              weight: 200
        - name: object
          object: True
          partition_power: 14
          replicas: 3
          hours: 1
          region: 1
          devices:
            - address: 10.0.20.8
              device: vdb
              zone: 1
              region: 1
              replication_ip: 10.0.30.4
              weight: 5120
            - address: 10.0.20.8
              device: vdc
              zone: 1
              region: 1
              replication_ip: 10.0.30.4
              weight: 5120
            - address: 10.0.20.9
              device: vdb
              zone: 1
              region: 1
              replication_ip: 10.0.30.5
              weight: 5120
            - address: 10.0.20.9
              device: vdc
              zone: 1
              region: 1
              replication_ip: 10.0.30.5
              weight: 5120
            - address: 10.0.20.10
              device: vdb
              zone: 2
              region: 1
              replication_ip: 10.0.30.9
              weight: 5120
            - address: 10.0.20.10
              device: vdc
              zone: 2
              region: 1
              replication_ip: 10.0.30.9
              weight: 5120
            - address: 10.0.20.11
              device: vdb
              zone: 2
              region: 1
              replication_ip: 10.0.30.6
              weight: 5120
            - address: 10.0.20.11
              device: vdc
              zone: 2
              region: 1
              replication_ip: 10.0.30.6
              weight: 5120
            - address: 10.0.20.12
              device: vdb
              zone: 1
              region: 1
              replication_ip: 10.0.30.8
              weight: 5120
            - address: 10.0.20.12
              device: vdc
              zone: 2
              region: 1
              replication_ip: 10.0.30.8
              weight: 5120