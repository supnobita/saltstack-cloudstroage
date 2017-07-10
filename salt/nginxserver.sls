#webserver
#install nginx and php
nginx:
    pkg.installed: []

php:
    pkg.installed:
     - pkgs:
       - php5-fpm 
       - php5-cli
       - php5-mysql
       - php-pear
       - php5-common
       - php5-curl
       - php5-dev
       - php5-gd
       - php5-json
       - php5-ldap
       - php5-memcached
       - php5-mysql
       - php5-readline
       - php5-redis

php-apcu.repo:
    pkgrepo.managed:
        - humanname: trusty-backports
        - name: deb http://de.archive.ubuntu.com/ubuntu/ trusty-backports main restricted universe multiverse
        - dist: trusty
        - file: /etc/apt/sources.list.d/trusty-backports
        - refresh_db: true
php5-apcu:
    pkg.installed: []
        
/etc/php5/fpm/php.ini:
    file.replace:
      - pattern: 'cgi.fix_pathinfo = 1'
      - repl: 'cgi.fix_pathinfo = 0'
      
/etc/php5/fpm/pool.d/www.conf:
  file.managed:
    - file_mode: 644
    - contents: |
        [www]
        user = www-data
        group = www-data

        listen = 127.0.0.1:9000

        listen.backlog = 65535

        listen.owner = www-data
        listen.group = www-data
        listen.mode = 0666


        pm = dynamic
        pm.max_children = 128
        pm.start_servers = 8
        pm.min_spare_servers = 8
        pm.max_spare_servers = 16
        pm.process_idle_timeout = 30
        pm.max_requests = 4096


        access.log = /var/log/php.\$pool.access.log


        rlimit_files = 1024000
        chdir = /

        catch_workers_output = yes

        env[PATH] = /usr/local/bin:/usr/bin:/bin
        env[TMP] = /tmp
        env[TMPDIR] = /tmp
        env[TEMP] = /tmp

        php_flag[display_errors] = off
        php_admin_value[error_log] = /var/log/php.www.err.log
        php_admin_flag[log_errors] = off

        php_admin_value[max_execution_time] = 300
        php_admin_value[max_input_time] = 300

/etc/nginx/sites-available/default:
  file.managed:
    - file_mode: 644
    - contents: |
        upstream php-handler {
        server 127.0.0.1:9000;
        #server unix:/var/run/php5-fpm.sock;
        }
        fastcgi_cache_path /usr/local/tmp/cache levels=1:2 keys_zone=OWNCLOUD:100m inactive=60m;
        server {
        set \$skip_cache 1;
        if (\$request_uri ~* "thumbnail.php")
        { set $skip_cache 0;
        }
        listen 443 ssl;
        server_name {{pillar['public_domain']}} www.{{pillar['public_domain']}};
        ssl_certificate /etc/ssl/nginx/{{pillar['public_domain']}}.crt;
        ssl_certificate_key /etc/ssl/nginx/{{pillar['public_domain']}}.key;
        # Add headers to serve security related headers
        # Before enabling Strict-Transport-Security headers please read into this topic first.
        #add_header Strict-Transport-Security "max-age=15552000; includeSubDomains";
        add_header X-Content-Type-Options nosniff;
        add_header X-Frame-Options "SAMEORIGIN";
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Robots-Tag none;
        add_header X-Download-Options noopen;
        add_header X-Permitted-Cross-Domain-Policies none;
        root /var/www/owncloud;
        index index.php;
        client_max_body_size 512M;
        fastcgi_buffers 128 512K;
        # Disable gzip to avoid the removal of the ETag header
        gzip on;
        #begin config purge cache
        fastcgi_cache_key "\$scheme\$request_method\$host\$request_uri";
        #fastcgi_cache_use_stale error timeout invalid_header http_500;
        fastcgi_ignore_headers Cache-Control Expires Set-Cookie;
        fastcgi_ignore_client_abort on;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
        #end purge cache
        proxy_connect_timeout  600s;
        proxy_send_timeout  600s;
        proxy_read_timeout  600s;
        # Uncomment if your server is build with the ngx_pagespeed module
        # This module is currently not supported.
        #pagespeed off;
        error_page 403 /core/templates/403.php;
        error_page 404 /core/templates/404.php;
        #rewrite ^/.well-known/carddav /remote.php/carddav/ permanent;
        #rewrite ^/.well-known/caldav /remote.php/caldav/ permanent;
        rewrite ^/caldav(.*)\$ /remote.php/caldav\$1 redirect;
        rewrite ^/carddav(.*)\$ /remote.php/carddav\$1 redirect;
        rewrite ^/webdav(.*)\$ /remote.php/webdav\$1 redirect;
        location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
        }
        location ~ ^/(?:\.htaccess|data|config|db_structure\.xml|README){
        deny all;
        }
        location / {
        # The following 2 rules are only needed with webfinger
        rewrite ^/.well-known/host-meta /public.php?service=host-meta last;
        rewrite ^/.well-known/host-meta.json /public.php?service=host-meta-json last;
        rewrite ^/.well-known/carddav /remote.php/carddav/ redirect;
        rewrite ^/.well-known/caldav /remote.php/caldav/ redirect;
        rewrite ^(/core/doc/[^\/]+/)\$ $1/index.html;
        try_files $uri \$uri/ =404;
        }
        location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)/ {
        return 404;
        }
        location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console) {
        return 404;
        }
        location ~ ^/(?:index|remote|public|cron|core/ajax/update|status|ocs/v[12]|updater/.+|ocs-provider/.+|core/templates/40[34])\.php(?:\$|/) {
        fastcgi_split_path_info ^(.+\.php)(/.*)\$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
        fastcgi_param HTTPS on;
        fastcgi_param modHeadersAvailable true; #Avoid sending the security headers twice
        fastcgi_param front_controller_active true;
        fastcgi_pass php-handler;
        fastcgi_intercept_errors on;
        #fastcgi_request_buffering off; #Available since nginx 1.7.11
        fastcgi_cache_bypass \$skip_cache;
        fastcgi_no_cache \$skip_cache;
        }
        location ~ ^/(?:updater|ocs-provider)(?:\$|/) {
        try_files \$uri \$uri/ =404;
        index index.php;
        }
        # Adding the cache control header for js and css files
        # Make sure it is BELOW the PHP block
        location ~* \.(?:css|js)\$ {
        try_files $uri /index.php$uri$is_args$args;
        add_header Cache-Control "public, max-age=7200";
        # Add headers to serve security related headers (It is intended to have those duplicated to the ones above)
        # Before enabling Strict-Transport-Security headers please read into this topic first.
        #add_header Strict-Transport-Security "max-age=15552000; includeSubDomains";
        add_header X-Content-Type-Options nosniff;
        add_header X-Frame-Options "SAMEORIGIN";
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Robots-Tag none;
        add_header X-Download-Options noopen;
        add_header X-Permitted-Cross-Domain-Policies none;
        # Optional: Don't log access to assets
        access_log off;
        expires 1d;
        }
        location ~* \.(?:svg|gif|png|html|ttf|woff|ico|jpg|jpeg)\$ {
        try_files $uri /index.php$uri$is_args$args;
        # Optional: Don't log access to other assets
        access_log off;
        }
        location ~* \.(?:htm)\$ {
        index index.htm;
        }
        location ~* \.(?:css|js)\$ {
        add_header Cache-Control "public, max-age=7200";
        add_header Strict-Transport-Security "max-age=15768000; includeSubDomains; preload;";
        add_header X-Content-Type-Options nosniff;
        add_header X-Frame-Options "SAMEORIGIN";
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Robots-Tag none;
        access_log off;
        }
        # Optional: Don't log access to other assets
        location ~* \.(?:jpg|jpeg|gif|bmp|ico|png|swf)\$ {
        access_log off;
        }
        }

/etc/ssl/PUBLIC_DOMAIN.key:
  file.managed:
    - name: /etc/ssl/{{pillar['public_domain']}}.key
    - file_mode: 644
    - contents_pillar: sslkey

/etc/ssl/PUBLIC_DOMAIN.crt:
  file.managed:
    - name: /etc/ssl/{{pillar['public_domain']}}.crt
    - file_mode: 644
    - contents_pillar: sslcrt
start_nginx:
    service.running: 
        - name: nginx
        - require: 
            - pkg: nginx