{%- from "odoo/map.jinja" import server with context %}
{%- if server.enabled %}

odoo_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

{{ server.source.address }}:
  git.latest:
  - target: /opt/odoo/app
  - branch: {{ server.source.get("branch", "10.0") }}
  - rev: {{ server.source.get("branch", "10.0") }}
  - depth: 1
  - fetch_tags: False
  - require:
    - pkg: odoo_packages
    - file: odoo_directories

odoo_requirements:
  virtualenv.manage:
  - name: /opt/odoo
  - requirements: /opt/odoo/app/requirements.txt
  - require:
    - pkg: odoo_packages

odoo_doc_requirements:
  virtualenv.manage:
  - name: /opt/odoo
  - requirements: /opt/odoo/app/doc/requirements.txt
  - require:
    - pkg: odoo_packages

odoo:
  user.present:
  - name: odoo
  - shell: /bin/bash
  - home: /opt/odoo

odoo_directories:
  file.directory:
  - names:
    - /var/log/odoo
    - /opt/odoo
  - user: odoo
  - group: odoo
  - makedirs: true
  - require:
    - user: odoo

/etc/odoo-server.conf:
  file.managed:
  - source: salt://odoo/files/odoo.conf
  - user: odoo
  - mode: 640
  - template: jinja

chown_odoo:
  cmd.run:
  - name: "chown odoo: /opt/odoo/ -R"
  - require:
    - file: /opt/odoo

{%- if grains.get('init', None) == 'systemd' %}

/etc/systemd/system/odoo-server.service:
  file.managed:
  - source: salt://odoo/files/odoo-server.service
  - mode: 755
  - template: jinja

odoo-service:
  service.enabled:
  - name: odoo-server
  - enable: true
  - require:
    - file: /etc/systemd/system/odoo-server.service

{%- else %}

/etc/init.d/odoo-server:
  file.managed:
  - source: salt://odoo/files/init
  - mode: 755
  - template: jinja

odoo-service:
  service.enabled:
  - name: odoo-server
  - enable: true
  - require:
    - file: /etc/init.d/odoo-server

{%- endif %}

{%- endif %}
