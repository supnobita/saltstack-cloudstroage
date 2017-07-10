#lamp-conf

apache2:
    pkg.installed: []
    
mysql-server:
    pkg.installed: []

/etc/mysql/my.cnf-br:
  file.managed:
    - name: /etc/mysql/conf.d/mysqld_owncloud.cnf
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True
    - contents: |
       [mysqld]
       bind-address = 0.0.0.0
       [mysqld]
       default-storage-engine = innodb
       innodb_file_per_table
       collation-server = utf8_general_ci
       init-connect = 'SET NAMES utf8'
       character-set-server = utf8


/etc/apache2/sites-available/owncloud.conf-new:
  file.managed:
    - name: /etc/apache2/sites-available/owncloud.conf
    - user: www-data
    - group: www-data
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True
    - contents: |
       #
       Alias /owncloud "/var/www/owncloud/"
       
       <Directory /var/www/owncloud/>
       Options +FollowSymlinks
       AllowOverride All
       
       <IfModule mod_dav.c>
       Dav off
       </IfModule>
       
       
       SetEnv HOME /var/www/owncloud
       SetEnv HTTP_HOME /var/www/owncloud
       
       </Directory>
       
       <IfModule mod_ssl.c>
       <VirtualHost _default_:443>
       ServerAdmin webmaster@localhost
       ServerName {{grains['fqdn']}}
       ServerAlias www.{{grains['fqdn']}}
       DocumentRoot /var/www/owncloud
       ErrorLog ${APACHE_LOG_DIR}/error.log
       CustomLog ${APACHE_LOG_DIR}/access.log combined
       SSLEngine on
       SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH
       SSLProtocol All -SSLv2 -SSLv3
       SSLHonorCipherOrder On
       SSLCertificateFile      /etc/ssl/{{grains['fqdn']}}.crt
       SSLCertificateKeyFile /etc/ssl/{{grains['fqdn']}}.key
       
       <Directory "/var/www/owncloud/">
       Options +FollowSymLinks
       AllowOverride All
       <IfModule mod_dav.c>
       Dav off
       </IfModule>
       SetEnv HOME /var/www/owncloud
       SetEnv HTTP_HOME /var/www/owncloud
       </Directory>
       
       <IfModule mod_headers.c>
       Header always set Strict-Transport-Security "max-age=15768000; includeSubDomains"
       </IfModule>
       <Directory "/var/www/owncloud/data">
       Require all denied
       </Directory>
       Alias Appclients /var/www/owncloud/Appclients
       <FilesMatch "\.(cgi|shtml|phtml|php)$">
       SSLOptions +StdEnvVars
       </FilesMatch>
       <Directory /usr/lib/cgi-bin>
       SSLOptions +StdEnvVars
       </Directory>
       BrowserMatch "MSIE [2-6]" \
       nokeepalive ssl-unclean-shutdown \
       downgrade-1.0 force-response-1.0
       BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown
       </VirtualHost>
       </IfModule>
       #
/etc/apache2/sites-enabled/owncloud.conf-new:
  file.symlink:
    - name: /etc/apache2/sites-enabled/owncloud.conf
    - target: /etc/apache2/sites-available/owncloud.conf
    
/etc/apache2/apache2.conf-servername:
  file.append:
    - name: /etc/apache2/apache2.conf
    - text: 'ServerName {{grains['fqdn']}}'
    
    
#Restart
apache2-run-at-boot-restart:
  service.running:
    - name: apache2
    - enable: True
    - watch:
      - pkg: apache2

mysql-run-at-boot-restart:
  service.running:
    - name: mysql
    - enable: True
    - watch:
      - pkg: mysql-server