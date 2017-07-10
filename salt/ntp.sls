#ntp
ntp:
  pkg.installed: []

/etc/ntp.conf0:
   file.comment:
    - name: /etc/ntp.conf
    - regex: 'server 0.ubuntu.pool.ntp.org'
   require:
    - pkg: ntp

/etc/ntp.conf1:
   file.comment:
    - name: /etc/ntp.conf
    - regex: 'server 1.ubuntu.pool.ntp.org'
   require:
    - pkg: ntp
/etc/ntp.conf2:
   file.comment:
    - name: /etc/ntp.conf
    - regex: 'server 2.ubuntu.pool.ntp.org'
   require:
    - pkg: ntp
/etc/ntp.conf3:
   file.comment:
    - name: /etc/ntp.conf
    - regex: 'server 3.ubuntu.pool.ntp.org'
   require:
    - pkg: ntp
/etc/ntp.conf4:
   file.replace:
    - name: /etc/ntp.conf
    - partern: 'server ntp.ubuntu.com'
    - repl: "server {{pillar['ntpip']}} iburst"
   require:
    - pkg: ntp
    
ntp-restart:
  service.running:
    - name: ntp
    - enable: True
    - reload: True
    - watch:
      - file: /etc/ntp.conf