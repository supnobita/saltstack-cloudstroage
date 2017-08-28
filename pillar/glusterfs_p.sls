#glusterfs.sls pillar
glusterfs_servers:
    web1: 
        ip: 192.168.0.4
        dev: vdb
    web2: 
        ip: 192.168.0.26
        dev: vdb
    web3:
        ip: 192.168.0.27
        dev: vdb
    web4: 
        ip: 192.168.0.28
        dev: vdb
    
