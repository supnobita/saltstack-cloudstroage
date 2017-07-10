mysql -u root -p{{ dbadminpass }} -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '{{keystone_db_pass}}'"
mysql -u root -p{{ dbadminpass }} -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '{{keystone_db_pass}}'"

