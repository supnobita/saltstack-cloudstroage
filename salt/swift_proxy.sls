#swift.sls

software-properties-common:
    pkg.installed: []

liberty.repo:
    cmd.run:
        - name: add-apt-repository cloud-archive:liberty

update.run:
    cmd.run:
        - name: apt-get update && apt-get -y dist-upgrade
        
python-openstackclient:
    pkg.installed: []
    

swift_pkg_installed:
    pkg.installed:
        - pkgs:
            - swift
            - swiftproxy
            - python-swiftclient
            - python-keystoneclient
            - python-keystonemiddleware
            - memcached
            - xfsprogs 
            - rsync
            - swift-account
            - swift-container
            
{% set swiftproxy = pillar['swiftproxy'] %}
{% set swiftproxy = pillar['keystoneusers'] %}
            
/etc/swift/proxy-server.conf:
    file.managed:
        - user: swift
        - group: swift
        - source: salt://file/template_swiftproxy.txt
        - template: jinja
        - defaults:
            bind_port: {{swiftproxy.port}}
            log_statsd_metric_prefix: {{swiftproxy.name}}
            keystoneusers.bind.public_address: {{ keystoneusers.bind.public_address }}
            keystoneusers.bind.public_port: {{keystoneusers.bind.public_port}}
            keystoneusers.bind.address: {{keystoneusers.bind.address}}
            keystoneusers.bind.private_port: {{keystoneusers.bind.private_port}}
            keystoneusers.swift_name: {{keystoneusers.swift_name}}
            keystoneusers.swift_password: {{keystoneusers.swift_password}}
            swiftproxy.memcache: {{swiftproxy.memcache}}
            swiftproxy.memcache_port: {{swiftproxy.memcache_port}}
            


/srv{{swiftproxy.disk_prefix}}:
    file.directory:
        - makedirs: True
        
        
{% for disk in swiftproxy.disks %}
cmd_format_{{loop.index}}:
    cmd.run:
        - name: "mkfs.xfs -i size=512 -n size=8192 {{disk}}"
        - require:
            - pkg: swift_pkg_installed
/srv{{disk}}:
    file.directory:
        - makedirs: True
 
append_fstab_{{loop.index}}:
    file.append:
        - name: /etc/fstab
        - text: {{disk}} /srv{{disk}} xfs noatime,nodiratime,nobarrier,logbufs=8 0 2
cmd_mount_{{loop.index}}:
    cmd.run:
    - name: "mount /srv{{disk}}"
    - require:
        - cmd: cmd_format_{{loop.index}}

{% endfor %}

/etc/rsyncd.conf:
    file.managed:
        - user: root
        - group: root
        - file_mode: 644
        - contents: |
            uid = swift
            gid = swift
            log file = /var/log/rsyncd.log
            pid file = /var/run/rsyncd.pid
            address = {{swiftproxy.ip}}
            [account]
            max connections = 10
            path = /srv{{swiftproxy.disk_prefix}}
            read only = False
            lock file = /var/lock/account.lock
            [container]
            max connections = 10
            path = /srv{{swiftproxy.disk_prefix}}
            read only = False
            lock file = /var/lock/container.lock
            [object]
            max connections = 10
            path = /srv{{swiftproxy.disk_prefix}}
            read only = False
            lock file = /var/lock/object.lock




/etc/default/rsync:
    file.replace:
      - pattern: 'RSYNC_ENABLE=false'
      - repl: 'RSYNC_ENABLE=true'
      
start_rsync:
    service.running: 
        - name: 
            - rsync
        - require: 
            - pkg: swift_pkg_installed
            
cmd_chown_swift_config_dir:
    cmd.run:
        - name: chown -R swift:swift /etc/swift/
        
cmd_chown_swift_data_dir:
    cmd.run:
        - name: chown -R swift:swift /srv{{swiftproxy.disk_prefix}}
        
        
        
        
create_cache_dir:
    file.directory:
        - name: /var/cache/swift
        - makedirs: True
        - user: swift
        - group: swift
        - dir_mode: 755


        
        
       
{%- for ring in swiftproxy.ring_builder.rings %}

{%- set ring_account = False %}
{%- set ring_container = False %}
{%- set ring_object = False %}

#loop and find ring type, enable particular ring type
{%- if ring.get('account', False) %}
    {%- set ring_account = True %}
{%- endif %}

{%- if ring.get('container', False) %}
    {%- set ring_container = True %}
{%- endif %}

{%- if ring.get('object', False) %}
    {%- set ring_object = True %}
{%- endif %}

#create ring and add device
{%- if ring_account == True %}
swift_ring_account_create:
    cmd.run:
    - name: swift-ring-builder account.builder create {{ ring.partition_power }} {{ ring.replicas }} {{ ring.hours }}
    - creates: /etc/swift/account.builder
    - require:
        - file: /etc/swift/swift.conf
{%- for device in ring.devices|sort %}
swift_ring_account_{{ device.address }}_{{loop.index}}:
  cmd.wait:
    - name: swift-ring-builder /etc/swift/account.builder add r{{ device.get('region', ring.region) }}z{{ device.get('zone', loop.index) }}-{{ device.address }}:{{device.get("account_port", 6002) }}/{{ device.device }} {{ device.get("weight", 100) }}
    - watch:
        - cmd: swift_ring_account_create
    - watch_in:
        - cmd: swift_ring_account_rebalance
{%- endfor %}
{%- set ring_account = False %}

{%- endif %}


{%- if ring_container== True %}
swift_ring_container_create:
    cmd.run:
        - name: swift-ring-builder container.builder create {{ ring.partition_power }} {{ ring.replicas }} {{ ring.hours }}
        - creates: /etc/swift/container.builder
        - require:
            - file: /etc/swift/swift.conf

{%- for device in ring.devices|sort %}

swift_ring_container_{{ device.address }}_{{loop.index}}:
    cmd.wait:
        - name: swift-ring-builder /etc/swift/container.builder add r{{ device.get('region', ring.region) }}z{{ device.get('zone', loop.index) }}-{{ device.address }}:{{ device.get("container_port", 6001) }}/{{ device.device }} {{ device.get("weight", 100) }}
        - watch:
            - cmd: swift_ring_container_create
        - watch_in:
            - cmd: swift_ring_container_rebalance

    {%- endfor %}
{%- set ring_container = False %}
{%- endif %}

{%- if ring_object == True %}
swift_ring_object_create}:
    cmd.run:
        - name: swift-ring-builder object.builder create {{ ring.partition_power }} {{ ring.replicas }} {{ ring.hours }}
        - creates: /etc/swift/object.builder
        - require:
          - file: /etc/swift/swift.conf
          
{%- for device in ring.devices|sort %}

swift_ring_object_{{ device.address }}_{{loop.index}}:
    cmd.wait:
        - name: swift-ring-builder /etc/swift/object.builder add r{{ device.get('region', ring.region) }}z{{ device.get('zone', loop.index) }}-{{ device.address }}:{{ device.get("object_port", 6000) }}/{{ device.device }} {{ device.get("weight", 100) }}
        - watch:
          - cmd: swift_ring_object_create
        - watch_in:
          - cmd: swift_ring_object_rebalance

{%- endfor %}
{%- set ring_object = False %}
{%- endif %}

{%- endfor %}

        


swift_ring_object_rebalance:
    cmd.wait:
    - name: swift-ring-builder /etc/swift/object-builder rebalance
    
swift_ring_container_rebalance:
    cmd.wait:
    - name: swift-ring-builder /etc/swift/container-builder rebalance
 
swift_ring_account_rebalance:
    cmd.wait:
    - name: swift-ring-builder /etc/swift/account-builder rebalance
        
/etc/swift/swift.conf:
    file.managed:
        - user: swift
        - group: swift
        - source: salt://file/template_swiftclient.txt
        - replace: true
memcached_start:
    service.running:
        - name: memcached
        - require:
            - pkg: swift_pkg_installed
            
restart_swift:
    cmd.run:
        - name: swift-init all start
        - require:
            - file: /etc/swift/swift.conf
        
        
        
        
        
        
        
        