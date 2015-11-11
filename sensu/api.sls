{% from "sensu/pillar_map.jinja" import sensu with context -%}

include:
  - sensu
  - sensu.rabbitmq_conf
  - sensu.redis_conf

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
          password: {{ sensu.api.password }}
          port: {{ sensu.api.port }}
          user: {{ sensu.api.user }}

sensu-api:
  service.running:
    - enable: True
    - require:
      - file: /etc/sensu/conf.d/api.json
      - file: /etc/sensu/conf.d/rabbitmq.json
      - file: /etc/sensu/conf.d/redis.json
    - watch:
      - file: /etc/sensu/conf.d/api.json
      - file: /etc/sensu/conf.d/rabbitmq.json
      - file: /etc/sensu/conf.d/redis.json
