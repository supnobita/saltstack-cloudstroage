#glusterfs

python-software-properties:
    pkg.installed: []

    
xfsprogs:
    pkg.installed: []
    

{% for name, host in pillar.get('glusterfs_servers', {}).items() %}

{% if host.ip in grains['ipv4'] %}
{% set diskname = host.dev %}
cmd_format:
    cmd.run:
        - name: mkfs.xfs -f -i size=512 -n size=8192 /dev/{{diskname}}

formatdisk:
    blockdev.formatted:
        - name: /dev/{{diskname}}
        - fs_type: xfs
        - onfail:
            - cmd.run: cmd_format

{% endif %}
{% endfor %}
            
glusterfs.repo:
    pkgrepo.managed:
        - humanname: glusterfsrepo
        - name: ppa:gluster/glusterfs-3.8
        - dist: trusty
        - file: /etc/apt/sources.list.d/gluster-glusterfs-3_8-trusty.list
        - keyid: 3FE869A9
        - keyserver: keyserver.ubuntu.com

glusterfs:
    pkg.installed:
        - pkgs:
            - glusterfs-server
            - glusterfs-client
            - nfs-common

glusterfs-server:
    service.running: 
        - name: 
            - glusterfs-server
        - require: 
            - glusterfs
        - watch: 
            - cmd: cmd_enable_nfs_option


glusterfs_peers:
    glusterfs.peered:
    - names: 
{% for name, host in pillar.get('glusterfs_servers', {}).items() %}
        - {{ host.ip }}
{% endfor %}

glusterfs_peers_wait:
  cmd.wait:
    - name: sleep 5
    - watch_in:
      - glusterfs: glusterfs_peers

/brick/gvdata:
    file.directory:
        - makedirs: True

glusterfs_create_volume:
    glusterfs.volume_present:
        - name: gvdata
        - bricks:
{% for name, host in pillar.get('glusterfs_servers', {}).items() %}
            - {{ host.ip }}:/brick/gvdata
{% endfor %}
        - start: True
        - replica: 2
        - transport: tcp
        - force: True
            
/etc/fstab:
    file.append:
        - text: localhost:/gvdata /var/www/owncloud/data nfs defaults,_netdev,rsize=4096,wsize=4096,noatime,nodiratime,hard,intr 0 0
        

/var/www/owncloud:
    file.directory:
        - makedirs: True
        - user: www-data
        - group: www-data

/var/www/owncloud/data:
    file.directory:
        - makedirs: True
        - user: www-data
        - group: www-data

cmd_enable_nfs_option:
    cmd.run:
        - name:  gluster volume set gvdata nfs.disable off
        

cmd_mount:
    cmd.run:
        - name: mount -a
    
