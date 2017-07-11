#keepalivedMaster.sls
#priority: 100 is master
#nopreempt: false is master
keepalived:
  cluster:
    enabled: True
    instance:
      VIP2:
        nopreempt: False
        priority: 100
        virtual_router_id: 52
        password: pass
        address: 10.0.0.253
        interface: eth1
