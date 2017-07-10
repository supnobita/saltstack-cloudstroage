#swift.sls

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
    
