#keystone.sls

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
    

echo "manual" > /etc/init/keystone.override:
    cmd.run: []
    
install-pkg:
    pkg.installed:
        - pkgs:
            - keystone 
            - nginx 
            - libgd-tools 
            - nginx-doc
            - python-pip
            - python-dev
            

            
pip install uwsgi:
    cmd.run: []
            
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
{% if 'keystone' in grains['roles'] %}
script-db.get:
    file.managed:
        - name: /tmp/keystone-mysql.sh
        - source: salt://file/keystone-mysql.sh
        - template: jinja
        - defaults:
            dbadminpass: {{pillar['dbadminpass']}}
            keystone_db_pass: {{pillar['keystone_db_pass']}}
            keystone_db_ip: {{pillar['keystone_db_ip']}}
            keystone_db_port: {{pillar['keystone_db_port']}}
        - require_in:
            - cmd: script-db.run
            
script-db.run:
    cmd.run:
        - name: sh /tmp/keystone-mysql.sh

create-keystone-database:
    cmd.run:
        - name: mysql -u root -p{{pillar['dbadminpass']}} -h {{pillar['keystone_db_ip']}} -P {{pillar['keystone_db_port']}} -e "create database keystone;"
            
/bin/sh -c "keystone-manage db_sync" keystone:
    cmd.run:
        - name: /bin/sh -c "keystone-manage db_sync" keystone; sleep 5
        - timeout: 120
        - require:
            - file: keystone_conf
    
{% endif %}
    
run_fernet_setup:
    cmd.run:
        - name: keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone

#chep key:
/etc/keystone/fernet-keys/0:
    file.managed:
        - text: izMX49dBqjONPEQFHFpq4OqukUme8LLhfOKwZ_QX9J0=
        - file_mode: 600
        - require: 
            - run_fernet_setup
        - replace: True
        
/etc/keystone/fernet-keys/1:
    file.managed:
        - text: Ac1SapyOYjOCRugLrMie^CCgu7_M91yNudmmqU5fp9E=
        - file_mode: 600
        - require: 
            - run_fernet_setup
        - replace: True

#can dong bo fernet - MANUAL cac key nay sang cac host khac nhau, dong bo key fernet 

#setup nginx front-end: keystone
#https://developer.rackspace.com/blog/keystone_horizon_nginx/
service nginx stop:
    cmd.run: []
    
/etc/init/keystone.conf:
    file.managed:
        - user: keystone
        - group: keystone
        - contents: |
            description "OpenStack Identity service"
            author "Thomas Goirand <zigo@debian.org>"
            start on runlevel [2345]
            stop on runlevel [!2345]
            chdir /var/run
            respawn
            respawn limit 20 5
            limit nofile 65535 65535
            pre-start script
            for i in lock run log lib ; do
            mkdir -p /var/$i/keystone
            chown keystone /var/$i/keystone
            done
            end script
            script
            [ -x "/usr/bin/keystone-all" ] || exit 0
            DAEMON_ARGS=""
            [ -r /etc/default/openstack ] && . /etc/default/openstack
            [ -r /etc/default/$UPSTART_JOB ] && . /etc/default/$UPSTART_JOB
            [ "x$USE_SYSLOG" = "xyes" ] && DAEMON_ARGS="$DAEMON_ARGS --use-syslog"
            [ "x$USE_LOGFILE" != "xno" ] && DAEMON_ARGS="$DAEMON_ARGS --log-file=/var/log/keystone/keystone.log"
            exec start-stop-daemon --start --chdir /var/lib/keystone \
            --chuid keystone:keystone --make-pidfile --pidfile /var/run/keystone/keystone.pid \
            --exec /usr/bin/keystone-all -- --config-file=/etc/keystone/keystone.conf ${DAEMON_ARGS}
            end script


/etc/nginx/sites-enabled/default:
    file.absent: []
        
    
/var/log/nginx/keystone:
    file.directory:
        - user: www-data
        - group: www-data
        
/var/www/keystone:
    file.directory:
        - user: www-data
        - group: www-data
        - makedirs: True
        
/var/www/keystone/admin:
    file.managed:
        - user: www-data
        - group: www-data
        - source: salt://file/tempalate_keystone_admin.txt
        
/var/www/keystone/main:
    file.managed:
        - user: www-data
        - group: www-data
        - source: salt://file/tempalate_keystone_main.txt
        
chmod ug+x /var/www/keystone/*:
    cmd.run: []
        
/etc/uwsgi:
    file.directory:
        - name: /etc/uwsgi
    
/etc/uwsgi/keystone-admin.ini:
    file.managed:
        - contents: |
            [uwsgi]
            master = true
            processes = 32
            threads = 4
            enable-threads = true
            chmod-socket = 666
            socket = /run/uwsgi/keystone-admin.socket
            pidfile = /run/uwsgi/keystone-admin.pid
            log-syslog = '[keystone-admin]'
            name = keystone
            uid = keystone
            gid = www-data
            chdir = /var/www/keystone/
            wsgi-file = /var/www/keystone/admin

/etc/uwsgi/keystone-main.ini:
    file.managed:
        - contents: |
            [uwsgi]
            master = true
            processes = 32
            # performance tunning
            #workers = 16
            threads = 4
            enable-threads = true
            chmod-socket = 666
            socket = /run/uwsgi/keystone-main.socket
            pidfile = /run/uwsgi/keystone-main.pid
            name = keystone
            uid = keystone
            gid = www-data
            log-syslog = '[keystone-main]'
            chdir = /var/www/keystone/
            wsgi-file = /var/www/keystone/main

            
/etc/init/uwsgi.conf:
    file.managed:
        - contents: |
            description "uwsgi for nginx keystone admin"
            start on runlevel [2345]
            stop on runlevel [!2345]
            respawn
            pre-start script
              if [ ! -d /run/uwsgi ]; then
                  mkdir /run/uwsgi/
                  chown keystone:keystone /run/uwsgi
                  chmod 775 /run/uwsgi
              fi
            end script
            post-stop script
              if [ -d /run/uwsgi ]; then
                 rm -r /run/uwsgi
              fi
            end script
            exec /usr/local/bin/uwsgi --master --emperor /etc/uwsgi
/etc/nginx/sites-available/keystone.conf:
    file.managed:
        - contents: |
            server {
            listen {% for name, host in pillar.get('keystoneip', {}).items() %} {% if  host.ip in  grains['ipv4'] %} {{host.port2}} {% endif %}{% endfor %};
            access_log /var/log/nginx/keystone/access.log;
            error_log /var/log/nginx/keystone/error.log;
            location / {
                uwsgi_pass      unix:///run/uwsgi/keystone-main.socket;
                include         uwsgi_params;
                uwsgi_param      SCRIPT_NAME   main;
             }
            }
            server {
            listen {% for name, host in pillar.get('keystoneip', {}).items() %} {% if  host.ip in  grains['ipv4'] %} {{host.port1}} {% endif %}{% endfor %};
            access_log /var/log/nginx/keystone/access.log;
            error_log /var/log/nginx/keystone/error.log;
            location / {
                uwsgi_pass      unix:///run/uwsgi/keystone-admin.socket;
                include         uwsgi_params;
                uwsgi_param      SCRIPT_NAME   admin;
            }
            }
/etc/nginx/sites-enabled/keystone.conf:
    file.symlink:
        - target: /etc/nginx/sites-available/keystone.conf
uwsgi:
    service.running:
        - name: uwsgi
nginx :
    service.running:
        - name: nginx 
        
/var/lib/keystone/keystone.db:
    file.absent:
        - name: /var/lib/keystone/keystone.db
        

