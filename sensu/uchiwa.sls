{% from "sensu/pillar_map.jinja" import sensu with context -%}
{% macro get(value, item) -%}
  {{ value.get(item, sensu.sites.get(item)) }}
{%- endmacro -%}
{%- set sites = salt['pillar.get']('sensu:uchiwa:sites').items() %}

include:
  - sensu

uchiwa:
  pkg.installed:
    - require:
      - pkgrepo: sensu
  file.serialize:
    - name: /etc/sensu/uchiwa.json
    - formatter: json
    - mode: 644
    - user: uchiwa
    - group: sensu
    - require:
      - pkg: uchiwa
    - dataset:
        sensu:
        {%- for site, value in sites %}
          - name: {{ site}},
            host: {{ get(value, 'host') }}
            ssl: {{ get(value, 'ssl') }}
            port: {{ get(value, 'port') }}
            user: {{ get(value, 'user') }}
            pass: {{ get(value, 'password') }}
            path: {{ get(value, 'path') }}
            timeout: {{ get(value, 'timeout') }}
        {%- endfor %}
        uchiwa:
          user: {{ sensu.uchiwa.user }}
          pass: {{ sensu.uchiwa.password }}
          port: {{ sensu.uchiwa.port }}
          stats: {{ sensu.uchiwa.stats }}
          refresh: {{ sensu.uchiwa.refresh }}

  service.running:
    - enable: True
    - require:
      - file: /etc/sensu/uchiwa.json
    - watch:
      - file: /etc/sensu/uchiwa.json

