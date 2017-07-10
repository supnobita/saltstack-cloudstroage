#keepalived_slave.sls
#priority: 150 is slave
keepalived:
  cluster:
    enabled: True
    instance:
      VIP2:
        nopreempt: True
        priority: 150
        virtual_router_id: 52
        password: pass
        address: 10.0.0.253
        interface: eth1