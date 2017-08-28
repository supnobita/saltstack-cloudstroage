#change config template

{% set swiftproxy = pillar.get('swiftproxy') %}
{% set keystoneusers = pillar.get('keystoneusers') %}

keystone_conf:
    file.managed:
        - name: /etc/keystone/keystone.conf
        - source: salt://file/template_keystone_conf.txt
        - template: jinja
        - defaults:
            keystone_admin_token: {{pillar['keystone_admin_token']}}
            keystone_db_pass: {{pillar['keystone_db_pass']}}
            memcache_ip: {{pillar['memcache_ip']}}
            memcache_port: {{pillar['memcache_port']}}
            keystone_db_ip: {{pillar['keystone_db_ip']}}
            keystone_db_port: {{pillar['keystone_db_port']}}

/etc/swift/proxy-server.conf:
    file.managed:
        - user: swift
        - group: swift
        - source: salt://file/template_swiftproxy.txt
        - template: jinja
        - defaults:
            bind_port: {{swiftproxy.port}}
            log_statsd_metric_prefix: {{swiftproxy.name}}
            private_address: {{ keystoneusers.bind.private_address }}
            public_port: {{keystoneusers.bind.public_port}}
            private_port: {{keystoneusers.bind.private_port}}
            swift_name: {{keystoneusers.swift_name}}
            swift_password: {{keystoneusers.swift_password}}
            memcache: {{pillar['memcache_ip']}}
            memcache_port: {{pillar['memcache_port']}}
            statdhost: {{swiftproxy.statdhost}}