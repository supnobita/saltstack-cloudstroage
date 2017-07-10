#haproxy.sls
#haproxy for keystone, db, redis
haproxy:
    pkg.installed: []
    file.managed: 
        - name: /etc/haproxy/haproxy.cfg
        - source: salt://file/template_haproxy_config.tp

keystone_admin_haproxy_conf:
    file.append: 
        - name: /etc/haproxy/haproxy.cfg
        - text: |
            listen keystone_admin_cluster
            bind {{pillar['keystone_vip']}}:35357
            balance leastconn
            maxconn 2000000
            option tcpka
            option httpchk
            option tcplog
{% for name, host in pillar.get('keystoneip', {}).items() %}
            server {{host.name}} {{host.ip}}:{{host.port1}} maxconn 5000 check inter 2000 rise 2 fall 5
{% endfor %}


keystone_public_haproxy_conf:
    file.append: 
        - name: /etc/haproxy/haproxy.cfg
        - text: |
            listen keystone_public_internal_cluster
            bind {{pillar['keystone_vip']}}:5000
            balance roundrobin
            maxconn 1000000
            option tcpka
            option httpchk
            option tcplog
{% for name, host in pillar.get('keystoneip', {}).items() %}
            server {{host.name}} {{host.ip}}:{{host.port2}} maxconn 5000 check inter 2000 rise 2 fall 5
{% endfor %}

galera_haproxy_conf:
    file.append: 
        - name: /etc/haproxy/haproxy.cfg
        - text: |
            listen galera_cluster
            bind {{pillar['galera_vip']}}:3306
            balance source
            maxconn 1000000
            mode tcp
            option tcpka
            option mysql-check user haproxy
{% for name, host in pillar.get('galeraip', {}).items() %}
            server {{host.name}} {{host.ip}}:{{host.port}} maxconn 5000 check inter 2000 rise 2 fall 5
{% endfor %}

haproxy-running:
    service.running:
        - name: haproxy
        - watch: 
            - galera_haproxy_conf
