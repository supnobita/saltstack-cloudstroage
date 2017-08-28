#keepalived_slave.sls
#priority: 150 is slave
keepalived:
  cluster:
    enabled: True
    instance:
      sqlproxy:
        nopreempt: True
        priority: 150
        virtual_router_id: 52
        password: pass
        address: 192.168.0.200
        interface: eth0