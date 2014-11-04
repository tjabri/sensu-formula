include:
  - sensu
  - sensu.rabbitmq_conf

/etc/sensu/conf.d/redis.json:
  file.managed:
    - source: salt://sensu/files/redis.json
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: sensu

/etc/sensu/conf.d:
  file.recurse:
    - source: salt://sensu/files/conf.d
    - template: jinja
    - require:
      - pkg: sensu
    - require_in:
      - service: sensu-server

/etc/sensu/extensions:
  file.recurse:
    - source: salt://sensu/files/extensions
    - file_mode: 555
    - require:
      - pkg: sensu
    - require_in:
      - service: sensu-server
    - watch_in:
      - service: sensu-server
   
/etc/sensu/mutators:
  file.recurse:
    - source: salt://sensu/files/mutators
    - file_mode: 555
    - require:
      - pkg: sensu
    - require_in:
      - service: sensu-server
    - watch_in:
      - service: sensu-server

/etc/sensu/handlers:
  file.recurse:
    - source: salt://sensu/files/handlers
    - file_mode: 555
    - require:
      - pkg: sensu
    - require_in:
      - service: sensu-server
    - watch_in:
      - service: sensu-server

sensu-server:
  service.running:
    - enable: True
    - require:
      - file: /etc/sensu/conf.d/redis.json
      - file: /etc/sensu/conf.d/rabbitmq.json
    - watch:
      - file: /etc/sensu/conf.d/*
