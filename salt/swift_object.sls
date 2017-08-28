#swift-object.sls
software-properties-common_swobject:
    pkg.installed:
        - name: software-properties-common

liberty.repo_swobject:
    cmd.run:
        - name: add-apt-repository cloud-archive:liberty

update.run_swobject:
    cmd.run:
        - name: apt-get update && apt-get -y dist-upgrade
        
python-openstackclient_swobject:
    pkg.installed:
        - name: python-openstackclient
    

swift_pkg_installed_swobject:
    pkg.installed:
        - pkgs:
            - swift
            - python-swiftclient
            - python-keystoneclient
            - python-keystonemiddleware
            - swift-object
            - xfsprogs 
            - rsync
            

rsync_config_swobject:
    file.append:
        - name: /etc/rsyncd.conf
        - text: |
            [object]
            max connections = 10
            path = /srv/dev/
            read only = false
            lock file = /var/lock/object.lock
            

{% set swiftproxy = pillar.get('swiftproxy') %}
{% set keystoneusers = pillar.get('keystoneusers') %}
            
{%- if swiftproxy['object_rep_port'] %}
rsync_config_rep_swobject:
    file.append:
        - name: /etc/rsyncd.conf
        - text: |
            [object{{swiftproxy.object_rep_port}}]
            max connections = 10
            path = /srv/dev/
            read only = false
            lock file = /var/lock/object{{swiftproxy.object_rep_port}}.lock
            
object_server_config_swobject:
    file.managed:
        - name: /etc/swift/object-server/object-server.conf
        - makedirs: True
        - file_mode: 644
        - dir_mode: 755
        - user: swift
        - group: swift
        - source: salt://file/template_swiftobject_config.txt
        - template: jinja
        - defaults:
            disk_prefix: {{swiftproxy.disk_prefix}}
            statdhost: {{swiftproxy.statdhost}}
            nodename: {{swiftproxy.nodename}}
            ip: {{swiftproxy.ip}}
        
            
object_replicator_confg:
    file.managed:
        - name: /etc/swift/object-server/object-replicator.conf
        - makedirs: True
        - file_mode: 644
        - dir_mode: 755
        - user: swift
        - group: swift
        - source: salt://file/template_swiftobject_replicator.txt
        - template: jinja
        - defaults:
            disk_prefix: {{swiftproxy.disk_prefix}}
            statdhost: {{swiftproxy.statdhost}}
            nodename: {{swiftproxy.nodename}}
            ip: {{swiftproxy.ip}}
            object_rep_port: {{swiftproxy.object_rep_port}}
            
{%- else %}
object_server_config:
    file.managed:
        - name: /etc/swift/object-server.conf
        - makedirs: True
        - file_mode: 644
        - dir_mode: 755
        - user: swift
        - group: swift
        - source: salt://file/template_swiftobject_config.txt
        - template: jinja
        - defaults:
            disk_prefix: {{swiftproxy.disk_prefix}}
            statdhost: {{swiftproxy.statdhost}}
            nodename: {{swiftproxy.nodename}}
            ip: {{swiftproxy.ip}}
{%- endif %}

/etc/default/rsync_swobject:
    file.replace:
      - name: /etc/default/rsync
      - pattern: 'RSYNC_ENABLE=false'
      - repl: 'RSYNC_ENABLE=true'

rsync_swobject:
    service.running: 
        - name: rsync
        - reload: True
        - watch: 
            - file: /etc/rsyncd.conf
    
/etc/swift/object-server.conf:
    file.absent: []
    
cmd_chown_swift_config_dir_swobject:
    cmd.run:
        - name: chown -R swift:swift /etc/swift/
        
cmd_chown_swift_data_dir_swobject:
    cmd.run:
        - name: chown -R swift:swift /srv{{swiftproxy.disk_prefix}}
        
create_cache_dir_swobject:
    file.directory:
        - name: /var/cache/swift
        - makedirs: True
        - user: swift
        - group: swift
        - dir_mode: 755

{%- for ring in swiftproxy.ring_builder.rings %}

{%- set ring_object = False %}


{%- if ring.get('object', False) %}
    {%- set ring_object = True %}
{%- endif %}

#create ring and add device

{%- if ring_object == True %}
swift_ring_object_create_swobject:
    cmd.run:
        - name: swift-ring-builder /etc/swift/object.builder create {{ ring.partition_power }} {{ ring.replicas }} {{ ring.hours }}
        - creates: /etc/swift/object.builder
        - require:
          - file: /etc/swift/swift.conf
          
{%- for device in ring.devices|sort %}

swift_ring_object_swobject_{{ device.address }}_{{loop.index}}:
    cmd.wait:
{%- if swiftproxy['object_rep_port'] %}
        - name: swift-ring-builder /etc/swift/object.builder add r{{ device.get('region', ring.region) }}z{{ device.get('zone', loop.index) }}-{{ device.address }}:{{ device.get("object_port", 6000) }}R{{ device.replication_ip }}:{{device.get("object_rep_port", 7000) }}/{{ device.device }} {{ device.get("weight", 100) }}
{%- else %}
        - name: swift-ring-builder /etc/swift/object.builder add r{{ device.get('region', ring.region) }}z{{ device.get('zone', loop.index) }}-{{ device.address }}:{{ device.get("object_port", 6000) }}/{{ device.device }} {{ device.get("weight", 100) }}
{%- endif %}
        - watch:
          - cmd: swift_ring_object_create
        - watch_in:
          - cmd: swift_ring_object_rebalance_swobject

{%- endfor %}
{%- set ring_object = False %}
{%- endif %}

{%- endfor %}

        

swift_ring_object_rebalance_swobject:
    cmd.run:
    - name: swift-ring-builder /etc/swift/object.builder rebalance
    
    
/etc/swift/swift.conf_swobject:
    file.managed:
        - name: /etc/swift/swift.conf
        - user: swift
        - group: swift
        - source: salt://file/template_swiftclient.txt
        - replace: true

#can setup memcache:

restart_swift_swobject:
    cmd.run:
        - name: swift-init all start
        - require:
            - file: /etc/swift/swift.conf
        - watch:
            - cmd: swift_ring_object_rebalance_swobject
            

