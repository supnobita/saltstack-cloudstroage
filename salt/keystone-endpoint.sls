#create identity and endpoint
{% set keystoneusers= pillar.get('keystoneusers') %}
{% set keystone_admin_token = pillar.get('keystone_admin_token') %}
{% set swift= pillar.get('swift') %}

keystone_keystone_service:
    keystone.service_present:
        - name: keystone
        - service_type: identity
        - description: 'VNPT OpenStack Identity'
        - connection_token: {{ keystone_admin_token }}
        - connection_endpoint: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.private_port }}/v2.0'

keystone_endpoint_v3_RegionOne:
    keystone.endpoint_present:
        - name: keystone
        - publicurl: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.public_port }}/v3'
        - internalurl: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.public_port }}/v3'
        - adminurl: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.private_port }}/v3'
        - url: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.private_port }}/v3'
        - region: 'RegionOne'
        - connection_token: {{ keystone_admin_token }}
        - connection_endpoint: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.private_port }}/v2.0'
        - require:
            - keystone: keystone_keystone_service


keystone_endpoint_v2_RegionOne:
  keystone.endpoint_present:
  - name: keystone
  - publicurl: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.public_port }}/v2.0'
  - internalurl: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.public_port }}/v2.0'
  - adminurl: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.private_port }}/v2.0'
  - region: 'RegionOne'
  - connection_token: {{ keystone_admin_token }}
  - connection_endpoint: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.private_port }}/v2.0'
  - api_version: v3
  - require:
    - keystone: keystone_keystone_service


keystone_endpoint_v2:
  keystone.endpoint_present:
  - name: keystone
  - publicurl: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.public_port }}/v2.0'
  - internalurl: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.public_port }}/v2.0'
  - adminurl: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.private_port }}/v2.0'
  - region: 'regionOne'
  - connection_token: {{ keystone_admin_token }}
  - connection_endpoint: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.private_port }}/v2.0'
  - require:
    - keystone: keystone_keystone_service

keystone_endpoint_v3:
  keystone.endpoint_present:
  - name: keystone
  - publicurl: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.public_port }}/v3'
  - internalurl: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.public_port }}/v3'
  - adminurl: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.private_port }}/v3'
  - region: 'regionOne'
  - connection_token: {{ keystone_admin_token }}
  - connection_endpoint: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.private_port }}/v2.0'
  - require:
    - keystone: keystone_keystone_service

#create roles;
keystone_roles:
  keystone.role_present:
  - names: {{ keystoneusers.roles }}
  - connection_token: {{ keystone_admin_token }}
  - connection_endpoint: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.private_port }}/v2.0'
  

#create project
project.admin:
    keystone.project_present:
        - name: admin
        - enabled: True
        - description: 'Admin Project'
        - connection_token: {{ keystone_admin_token }}
        - connection_endpoint: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.private_port }}/v2.0'
    
project.service:
    keystone.project_present:
        - name: service
        - enabled: True
        - description: 'Service Project'
        - connection_token: {{ keystone_admin_token }}
        - connection_endpoint: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.private_port }}/v2.0'

project.demo:
    keystone.project_present:
        - name: demo
        - enabled: True
        - description: 'Demo Project'
        - connection_token: {{ keystone_admin_token }}
        - connection_endpoint: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.private_port }}/v2.0'

#create user        
keystone_admin_user:
  keystone.user_present:
  - name: {{ keystoneusers.admin_name }}
  - password: {{ keystoneusers.admin_password }}
  - email: {{ keystoneusers.admin_email }}
  - project: {{ keystoneusers.admin_project }}
  - roles:
      {{ keystoneusers.admin_project }}:
      - admin
  - connection_token: {{ keystone_admin_token }}
  - connection_endpoint: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.private_port }}/v2.0'
  - require:
    - keystone: project.admin
    - keystone: keystone_roles

keystone_demo_user:
  keystone.user_present:
  - name: {{ keystoneusers.demo_name }}
  - password: {{ keystoneusers.demo_pass }}
  - email: {{ keystoneusers.demo_email }}
  - project: {{ keystoneusers.demo_project }}
  - roles:
      {{ keystoneusers.demo_project }}:
      - member
  - connection_token: {{ keystone_admin_token }}
  - connection_endpoint: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.private_port }}/v2.0'
  - require:
    - keystone: project.demo
    - keystone: keystone_roles

keystone_swift_user:
  keystone.user_present:
  - name: {{ keystoneusers.swift_name }}
  - password: {{ keystoneusers.swift_password }}
  - project: {{ keystoneusers.service_project }}
  - email: {{ keystoneusers.demo_email }}
  - roles:
      {{ keystoneusers.service_project }}:
      - admin
  - connection_token: {{ keystone_admin_token }}
  - connection_endpoint: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.private_port }}/v2.0'
  - require:
    - keystone: project.service
    - keystone: keystone_roles
    

#SWIFT 
keystone_swift_service:
  keystone.service_present:
  - name: swift
  - service_type: object-store
  - description: 'VNPT OpenStack Swift Object Storage'
  - connection_token: {{ keystone_admin_token }}
  - connection_endpoint: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.private_port }}/v2.0'

swift_endpoint_regionOne:
  keystone.endpoint_present:
  - name: swift
  - publicurl: 'http://{{ swift.keystone_endpoint.private_address }}:{{ swift.keystone_endpoint.public_port }}/v1/AUTH_%(tenant_id)s'
  - internalurl: 'http://{{ swift.keystone_endpoint.private_address }}:{{ swift.keystone_endpoint.public_port }}/v1/AUTH_%(tenant_id)s'
  - adminurl: 'http://{{ swift.keystone_endpoint.private_address }}:{{ swift.keystone_endpoint.private_port }}/v1'
  - region: 'regionOne'
  - connection_token: {{ keystone_admin_token }}
  - connection_endpoint: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.private_port }}/v2.0'
  - require:
    - keystone: keystone_swift_service

swift_endpoint_RegionOne:
  keystone.endpoint_present:
  - name: swift
  - publicurl: 'http://{{ swift.keystone_endpoint.private_address }}:{{ swift.keystone_endpoint.public_port }}/v1/AUTH_%(tenant_id)s'
  - internalurl: 'http://{{ swift.keystone_endpoint.private_address }}:{{ swift.keystone_endpoint.public_port }}/v1/AUTH_%(tenant_id)s'
  - adminurl: 'http://{{ swift.keystone_endpoint.private_address }}:{{ swift.keystone_endpoint.private_port }}/v1'
  - region: 'RegionOne'
  - connection_token: {{ keystone_admin_token }}
  - connection_endpoint: 'http://{{ keystoneusers.bind.private_address }}:{{ keystoneusers.bind.private_port }}/v2.0'
  - require:
    - keystone: keystone_swift_service
    