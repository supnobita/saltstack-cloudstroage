#owncloud.sls

owncloud_wget:
    cmd.run:
      - name: "wget --no-check-certificate -O owncloud.gz.tar {{pillar['link_owncloud']}}"
      - cwd: /tmp
      
extract_owncloud:
  archive.extracted:
    - name: /var/www/owncloud
    - source: /tmp/owncloud.gz.tar
    - user: www-data
    - group: www-data
