{% from "sensu/pillar_map.jinja" import sensu with context -%}

include:
  - sensu

/etc/sensu/conf.d/api.json:
  file.serialize:
    - formatter: json
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: sensu
    - dataset:
        api:
          host: {{ sensu.api.host }}
          {% if sensu.api.password %}password: {{ sensu.api.password }}{% endif %}
          port: {{ sensu.api.port }}
          {% if sensu.api.user %}user: {{ sensu.api.user }}{% endif %}
          {% if sensu.api.bind %}bind: {{ sensu.api.bind }}{% endif %}

