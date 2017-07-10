#proftpd.sls

proftpd:
    pkg.installed:
        - pkgs:
            - proftpd-mod-mysql
            - proftpd-basic

/etc/proftpd/proftpd.conf:
  file.managed:
    - file_mode: 644
    - contents: |
        Include /etc/proftpd/modules.conf
        UseIPv6                         on
        IdentLookups                    off
        ServerName                      "Debian"
        ServerType                      standalone
        DeferWelcome                    off
        MultilineRFC2228                on
        DefaultServer                   on
        ShowSymlinks                    on
        TimeoutNoTransfer               600
        TimeoutStalled                  600
        TimeoutIdle                     1200
        DisplayLogin                    welcome.msg
        DisplayChdir                    .message true
        ListOptions                     "-l"
        DenyFilter                      \*.*/
        Port                            21
        <IfModule mod_dynmasq.c>
        </IfModule>
        MaxInstances                    30
        User                            proftpd
        Group                           nogroup
        Umask                           022  022
        AllowOverwrite                  on
        TransferLog /var/log/proftpd/xferlog
        SystemLog   /var/log/proftpd/proftpd.log
        <IfModule mod_ratio.c>
        Ratios off
        </IfModule>
        <IfModule mod_delay.c>
        DelayEngine on
        </IfModule>
        <IfModule mod_ctrls.c>
        ControlsEngine        off
        ControlsMaxClients    2
        ControlsLog           /var/log/proftpd/controls.log
        ControlsInterval      5
        ControlsSocket        /var/run/proftpd/proftpd.sock
        </IfModule>
        <IfModule mod_ctrls_admin.c>
        AdminControlsEngine off
        </IfModule>
        Include /etc/proftpd/sql.conf
        Include /etc/proftpd/conf.d/
/etc/proftpd/sql.conf:
  file.managed:
    - file_mode: 644
    - contents: |
        <IfModule mod_sql.c>
        DefaultRoot ~
        SQLBackend              mysql
        # The passwords in MySQL are encrypted using CRYPT
        SQLAuthTypes            OpenSSL Crypt
        SQLAuthenticate         users groups
        SQLConnectInfo  proftpd@localhost prouser proftpd@345qwe
        SQLUserInfo     ftpuser userid passwd uid gid homedir shell
        SQLGroupInfo    ftpgroup groupname gid members
        SQLMinID        500
        CreateHome on
        SQLLog PASS updatecount
        SQLNamedQuery updatecount UPDATE "count=count+1, accessed=now() WHERE userid='%u'" ftpuser
        SQLLog  STOR,DELE modified
        SQLNamedQuery modified UPDATE "modified=now() WHERE userid='%u'" ftpuser
        SqlLogFile /var/log/proftpd/sql.log
        RootLogin off
        RequireValidShell off
        </IfModule>
        <IfModule mod_quotatab.c>
        QuotaEngine on
        QuotaLog /var/log/proftpd/quota.log
        <IfModule mod_quotatab_sql.c>
        SQLNamedQuery get-quota-limit SELECT "* FROM ftpquotalimits WHERE name = '%{0}' AND quota_type = '%{1}'"
        SQLNamedQuery get-quota-tally SELECT "* FROM ftpquotatallies WHERE name = '%{0}' AND quota_type = '%{1}'"
        SQLNamedQuery update-quota-tally UPDATE "bytes_in_used = bytes_in_used + %{0}, bytes_out_used = bytes_out_used + %{1}, bytes_xfer_used = bytes_xfer_used + %{2}, files_in_used = files_in_used + %{3}, files_out_used = files_out_used + %{4}, files_xfer_used = files_xfer_used + %{5} WHERE name = '%{6}' AND quota_type = '%{7}'" ftpquotatallies
        SQLNamedQuery insert-quota-tally INSERT "%{0}, %{1}, %{2}, %{3}, %{4}, %{5}, %{6}, %{7}" ftpquotatallies
        QuotaLock /var/lock/ftpd.quotatab.lock
        QuotaLimitTable sql:/get-quota-limit
        QuotaTallyTable sql:/get-quota-tally/update-quota-tally/insert-quota-tally
        </IfModule>
        </IfModule>
        
/etc/proftpd/modules.conf:
  file.managed:
    - file_mode: 644
    - contents: |
        ModulePath /usr/lib/proftpd
        ModuleControlsACLs insmod,rmmod allow user root
        ModuleControlsACLs lsmod allow user *
        LoadModule mod_ctrls_admin.c
        LoadModule mod_tls.c
        LoadModule mod_sql.c
        LoadModule mod_sql_mysql.c
        LoadModule mod_radius.c
        LoadModule mod_quotatab.c
        LoadModule mod_quotatab_file.c
        LoadModule mod_quotatab_sql.c
        LoadModule mod_quotatab_radius.c
        LoadModule mod_wrap.c
        LoadModule mod_rewrite.c
        LoadModule mod_load.c
        LoadModule mod_ban.c
        LoadModule mod_wrap2.c
        LoadModule mod_wrap2_file.c
        LoadModule mod_dynmasq.c
        LoadModule mod_exec.c
        LoadModule mod_shaper.c
        LoadModule mod_ratio.c
        LoadModule mod_site_misc.c
        LoadModule mod_sftp.c
        LoadModule mod_sftp_pam.c
        LoadModule mod_facl.c
        LoadModule mod_unique_id.c
        LoadModule mod_copy.c
        LoadModule mod_deflate.c
        LoadModule mod_ifversion.c
        LoadModule mod_tls_memcache.c
        LoadModule mod_ifsession.c
/etc/hosts:
    file.append:
        - text: 127.0.0.1 {{grains['host']}}

proftpd-running:
    service.running:
        - name: proftpd
        - watch: 
            - pkg: proftpd
        - enable: True
        

