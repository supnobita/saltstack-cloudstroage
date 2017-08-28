#keepalivedMaster.sls
#priority: 100 is master
#nopreempt: false is master
keepalived:
  cluster:
    enabled: True
    instance:
      sqlproxy:
        nopreempt: False
        priority: 100
        virtual_router_id: 52
        password: pass
        address: 192.168.0.200
        interface: eth0
