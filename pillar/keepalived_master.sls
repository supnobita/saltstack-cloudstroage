#keepalivedMaster.sls
#priority: 100 is master
keepalived:
  cluster:
    enabled: True
      VIP2:
        nopreempt: True
        priority: 100
        virtual_router_id: 52
        password: pass
        address: 10.0.0.253
        interface: eth1