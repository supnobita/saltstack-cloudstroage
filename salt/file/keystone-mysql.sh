mysql -u root -p{{ dbadminpass }} -h {{keystone_db_ip}} -P {{keystone_db_port}} -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'192.168.0.%' IDENTIFIED BY '{{keystone_db_pass}}'"
mysql -u root -p{{ dbadminpass }} -h {{keystone_db_ip}} -P {{keystone_db_port}} -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'192.168.0.%' IDENTIFIED BY '{{keystone_db_pass}}'"

