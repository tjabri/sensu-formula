{% from "sensu/pillar_map.jinja" import sensu with context %}
{% from "sensu/configfile_map.jinja" import files with context %}
include:
  - sensu

/etc/sensu/conf.d/rabbitmq.json:
  file.managed:
    - source: salt://sensu/files/rabbitmq.json
    - template: jinja
    - user: {{files.files.user}}
    - group: {{files.files.group}}
    - makedirs: True
    {% if grains['os_family'] != 'Windows' %}
    - mode: 644
    {% endif %}

{%- if salt['pillar.get']('sensu:ssl:enable', false) %}
/etc/sensu/ssl:
  file.directory:
    - user: sensu
    - group: sensu
    - require:
      - pkg: sensu

/etc/sensu/ssl/key.pem:
  file.managed:
    - contents_pillar: sensu:ssl:key_pem
    - require:
      - file: /etc/sensu/ssl

/etc/sensu/ssl/cert.pem:
  file.managed:
    - contents_pillar: sensu:ssl:cert_pem
    - require:
      - file: /etc/sensu/ssl
{%- endif %}
