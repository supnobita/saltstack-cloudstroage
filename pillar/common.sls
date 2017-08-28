#common pillar

#ntp ip address
ntpip: 192.168.0.4
public_domain: vnptdrive.vinaphone.com.vn
keystone_vip: 192.168.0.210
galera_vip: 192.168.0.201
dbadminpass: db@SI@345qwe020817
keystone_db_pass: admin345qwedb
keystone_admin_token: 0f71cd75380e84abbeedXyZ
keystone_db_ip: 192.168.0.200
keystone_db_port: 6033
memcache_ip: 192.168.0.200
memcache_port: 22122

redisip:
    redis1: 
        name: redis1
        ip: 192.168.0.29
        port: 6379
    redis2: 
        ip: 192.168.0.30
        port: 6379
        name: redis2
galeraip:
    db0: 
        ip: 192.168.0.11
        name: db0
        port: 3307
        role: dbmaster
    db1: 
        ip: 192.168.0.4
        name: db1
        port: 3307
        role: dbslave1
    db2: 
        ip: 192.168.0.26
        name: db2
        port: 3307
        role: dbslave2
    db3: 
        ip: 192.168.0.27
        name: db3
        port: 3307
        role: dbslave3
    db4: 
        ip: 192.168.0.28
        name: db4
        port: 3307
        role: dbslave4
        


keystoneip:
    controller1: 
        name: controller1
        ip: 192.168.0.32
        port1: 35358
        port2: 5001
    controller2: 
        name: controller2
        ip: 192.168.0.33
        port1: 35358
        port2: 5001
    controller3: 
        name: controller3
        ip: 192.168.0.34
        port1: 35358
        port2: 5001
    controller4: 
        name: controller4
        ip: 192.168.0.35
        port1: 35358
        port2: 5001
        
        
        
keystoneusers:
    service_tenant: 'service'
    service_password: 'service@123qwe'
    admin_project: admin
    admin_name: admin
    admin_password: admin@345qwe
    admin_email: 'minhtri@vnpt.vn'
    service_project: service
    demo_name: demo
    demo_pass: demo@345qwe
    demo_email: 'minhtri@vnpt.vn'
    demo_project: demo
    swift_name: swift
    swift_password: swift@345qwe
    connection_endpoint: http://192.168.0.32:35358/v2.0
    roles:
      - admin
      - member
      - image_manager
      - service
    bind: #default binding
        private_address: keystone.vnptdrive.local
        private_port: 35357
        public_port: 5000
        
swift:
    keystone_endpoint:
        private_address: swiftproxy.vnptdrive.local
        private_port: 8080
        public_port: 8080
