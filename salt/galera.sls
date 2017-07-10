#galera.sls
#install mariadb-galera
#just install va config galera, but need more config
#run the mysql-safe and type password
#run the reboot mysql
#https://github.com/salt-formulas/salt-formula-galera/blob/master/galera

python-software-properties:
    pkg.installed: []
#set password admin:
setpass-admin.run:
    cmd.run:
        - name: echo mysql-server mysql-server/root_password password {{pillar['dbadminpass']}} | debconf-set-selections

setpass-admin-again.run:
    cmd.run:
        - name: echo mysql-server mysql-server/root_password_again password {{pillar['dbadminpass']}} | debconf-set-selections

mariadb-galera.repo:
    pkgrepo.managed:
        - humanname: mariadb-galera
        - name: deb http://mirror.jmu.edu/pub/mariadb/repo/5.5/ubuntu trusty main
        - dist: trusty
        - file: /etc/apt/sources.list.d/ubuntu-mariadb-galera-5.5.list
        - gpgkey: 0xcbcb082a1bb943db
        - gpgcheck: 1
        - keyserver: keyserver.ubuntu.com
        - require_in:
            - pkg: lasted.mariadb-galera
        
lasted.mariadb-galera:
    pkg.installed:
        - pkgs:
            - mariadb-galera-server
            - mariadb-client
            - galera-3
        - refresh: true
        - force_yes: true

{% set dbport = 1%}
{% set dbip = 1 %}
{% set dbrole = 1 %}
            
{% for name, dbhost in pillar.get('galeraip', {}).items() %}
    {% if dbhost.role in grains['roles'] %}
        {% set dbport = dbhost.port %}
        {% set dbip = dbhost.ip %}
        {% set dbrole = dbhost.role %}

mariadb-galera-test.conf:
    file.managed:
        - name: /etc/mysql/my.cnf
        - contents: |
            [client]
            port            = 3306
            socket          = /var/run/mysqld/mysqld.sock
            [mysqld_safe]
            socket          = /var/run/mysqld/mysqld.sock
            nice            = 0
            [mysqld]
            datadir=/var/lib/mysql
            socket=/var/lib/mysql/mysql.sock
            user=mysql
            binlog_format=ROW
            bind-address=0.0.0.0
            port= {{dbport}}
            default_storage_engine=innodb
            innodb_autoinc_lock_mode=2
            innodb_flush_log_at_trx_commit=0
            innodb_buffer_pool_size=122M
            wsrep_provider=/usr/lib/libgalera_smm.so
            wsrep_provider_options="gcache.size=300M; gcache.page_size=300M"
            wsrep_cluster_name="example_cluster"
            wsrep_cluster_address="gcomm://{% for name, host in pillar.get('galeraip', {}).items() %}{{host.ip}}{% if not loop.last %},{% endif %}{% endfor %}"
            wsrep_sst_method=rsync
            [mysql_safe]
            log-error=/var/log/mysqld.log
            pid-file=/var/run/mysqld/mysqld.pid
        
mariadb-galera.conf:
    file.managed:
        - name: /etc/mysql/my.cnf
        - onfail:
            - file: mariadb-galera-test.conf
        - contents: |
            [client]
            port            = 3306
            socket          = /var/run/mysqld/mysqld.sock
            [mysqld_safe]
            socket          = /var/run/mysqld/mysqld.sock
            nice            = 0
            [mysqld]
            user            = mysql
            pid-file        = /var/run/mysqld/mysqld.pid
            socket          = /var/run/mysqld/mysqld.sock
            port            = {{dbport}}
            basedir         = /usr
            datadir         = /var/lib/mysql
            tmpdir          = /tmp
            lc_messages_dir = /usr/share/mysql
            lc_messages     = en_US
            # phu: comment
            #skip-external-locking
            max_connections         = 3000
            connect_timeout         = 50
            wait_timeout            = 28000
            max_allowed_packet      = 100M
            thread_cache_size       = 128
            sort_buffer_size        = 4M
            bulk_insert_buffer_size = 16M
            tmp_table_size          = 32M
            max_heap_table_size     = 32M
            myisam_recover          = BACKUP
            key_buffer_size         = 128M
            table_open_cache        = 400
            myisam_sort_buffer_size = 512M
            concurrent_insert       = 2
            read_buffer_size        = 2M
            read_rnd_buffer_size    = 1M
            query_cache_limit               = 128K
            #query_cache_size                = 64M
            log_warnings            = 2
            slow_query_log = 1
            slow_query_log_file     = /var/log/mysql/mariadb-slow.log
            long_query_time = 1
            log_slow_verbosity      = query_plan
            log_bin                 = /var/log/mysql/mariadb-bin
            log_bin_index           = /var/log/mysql/mariadb-bin.index
            expire_logs_days        = 10
            max_binlog_size         = 100M
            default_storage_engine  = InnoDB
            innodb_log_buffer_size  = 8M
            innodb_file_per_table   = 1
            innodb_open_files       = 400
            innodb_io_capacity      = 400
            innodb_flush_method     = O_DIRECT
            datadir=/var/lib/mysql
            socket=/var/lib/mysql/mysql.sock
            user=mysql
            binlog_format=ROW
            bind-address={{dbip}}
            default_storage_engine=innodb
            innodb_autoinc_lock_mode=2
            innodb_flush_log_at_trx_commit=0
            innodb_buffer_pool_size=1G
            innodb_file_per_table=1
            innodb_log_buffer_size=128M
            wsrep_provider=/usr/lib/libgalera_smm.so
            wsrep_provider_options="gcache.size=300M; gcache.page_size=300M"
            wsrep_cluster_name="DBcluster"
            wsrep_cluster_address="gcomm://{% for name, host in pillar.get('galeraip', {}).items() %}{{host.ip}}{% if not loop.last %},{% endif %}{% endfor %}"
            wsrep_node_name=MyNode{{grains.host}}
            wsrep_node_address="{{dbip}}"
            wsrep_sst_method=rsync
            wsrep_slave_threads=64
            query_cache_size=0
            query_cache_type=0
            log-output=file
            [mysqldump]
            quick
            quote-names
            max_allowed_packet      = 16M
            [mysql]
            [isamchk]
            key_buffer              = 16M
            !includedir /etc/mysql/conf.d/
            [mysql_safe]
            log-error=/var/log/mysqld.log
            pid-file=/var/run/mysqld/mysqld.pid

galera_overide:
  file.managed:
  - name: /etc/init/mysql.override
  - contents: |
      limit nofile 102400 102400
      exec /usr/bin/mysqld_safe
  - require:
    - pkg: lasted.mariadb-galera
    

galera_stop:
    cmd.run:
        - name: service mysql stop
    
    {%- if dbrole == 'dbmaster' %}
galera_start:
    cmd.run:
        - name: /etc/init.d/mysql start --wsrep-new-cluster
        
galera_start_2:
    cmd.run:
        - name: /etc/init.d/mysql start --wsrep-new-cluster
        - onfail:
            - cmd.run: galera_start
proftp_mysql_db:
    file.managed:
        - name: /tmp/proftp_mysql_db.sh
        - source: salt://file/proftp-mysql.sh
        - template: jinja
        - defaults:
            dbadminpass: {{pillar['dbadminpass']}}

proftp_mysql_db_run:
    cmd.run:
        - name: sh /tmp/proftp_mysql_db.sh
        - watch:
            - file: proftp_mysql_db

    {% else %}
galera_start:
    cmd.run:
        - name: /etc/init.d/mysql start
        
galera_start_2:
    cmd.run:
        - name: /etc/init.d/mysql start
        - onfail:
            - cmd.run: galera_start
    {% endif %}
    
    {% endif %}
{% endfor %}
