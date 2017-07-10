mysql -u root -p{{ dbadminpass }} -e "GRANT SELECT, INSERT, UPDATE, DELETE ON proftpd.* TO 'prouser'@'%' IDENTIFIED BY 'proftpd@345qwe';"
mysql -u root -p{{ dbadminpass }} -e 'create database proftpd;'
mysql -u root -p{{ dbadminpass }} -e "\
CREATE TABLE proftpd.ftpgroup (\
groupname varchar(16) NOT NULL default '',\
gid smallint(6) NOT NULL default '5500',\
members varchar(16) NOT NULL default '',\
KEY groupname (groupname)\
) ENGINE=InnoDB ;"

mysql -u root -p{{ dbadminpass }} -e "\
CREATE TABLE proftpd.ftpquotalimits (\
name varchar(30) default NULL,\
quota_type enum('user','group','class','all') NOT NULL default 'user',\
per_session enum('false','true') NOT NULL default 'false',\
limit_type enum('soft','hard') NOT NULL default 'soft',\
bytes_in_avail bigint(20) unsigned NOT NULL default '0',\
bytes_out_avail bigint(20) unsigned NOT NULL default '0',\
bytes_xfer_avail bigint(20) unsigned NOT NULL default '0',\
files_in_avail int(10) unsigned NOT NULL default '0',\
files_out_avail int(10) unsigned NOT NULL default '0',\
files_xfer_avail int(10) unsigned NOT NULL default '0'\
) ENGINE=InnoDB;"

mysql -u root -p{{ dbadminpass }} -e "\
CREATE TABLE proftpd.ftpquotatallies (\
name varchar(30) NOT NULL default '',\
quota_type enum('user','group','class','all') NOT NULL default 'user',\
bytes_in_used bigint(20) unsigned NOT NULL default '0',\
bytes_out_used bigint(20) unsigned NOT NULL default '0',\
bytes_xfer_used bigint(20) unsigned NOT NULL default '0',\
files_in_used int(10) unsigned NOT NULL default '0',\
files_out_used int(10) unsigned NOT NULL default '0',\
files_xfer_used int(10) unsigned NOT NULL default '0'\
) ENGINE=InnoDB;"
mysql -u root -p{{ dbadminpass }} -e "\
CREATE TABLE proftpd.ftpuser (\
id int(10) unsigned NOT NULL auto_increment,\
userid varchar(32) NOT NULL default '',\
passwd varchar(32) NOT NULL default '',\
uid smallint(6) NOT NULL default '5500',\
gid smallint(6) NOT NULL default '5500',\
homedir varchar(255) NOT NULL default '',\
shell varchar(16) NOT NULL default '/sbin/nologin',\
count int(11) NOT NULL default '0',\
accessed datetime NOT NULL default '0000-00-00 00:00:00',\
modified datetime NOT NULL default '0000-00-00 00:00:00',\
PRIMARY KEY (id),\
UNIQUE KEY userid (userid)\
) ENGINE=InnoDB COMMENT='ProFTP user table';"
