sensu-formula
================

A saltstack formula to install and configure the open source monitoring framework, [Sensu](http://sensuapp.org/).

    See the full [Salt Formulas installation and usage instructions]
    (http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html).

Sensu can be configured/scaled with the individual states installed on multiple servers. All states are configured via the pillar file. Sane defaults are set in pillar_map.jinja and can be over-written in the pillar.

    This formula only manages Sensu!! 
    You are responsible for installing/configuring 
    RabbitMQ and Redis as appropriate.

Example top.sls:
```
base:
    '*':
        - sensu.client 

    'sensu-server-*':
        - sensu.server

    'sensu-api-*':
        - sensu.api

    'uchiwa-*':
        - sensu.uchiwa
```

Available states
================
* [sensu](#sensu)
* [sensu.server](#sensuserver)
* [sensu.client](#sensuclient)
* [sensu.api](#sensuapi)
* [sensu.uchiwa](#sensuuchiwa)

``sensu``
------------

Adds the Sensu repository, and installs the Sensu package.

``sensu.server``
------------

Configures sensu-server and starts the service.

Requires minimum rabbitmq configuration. 
```
sensu:
  rabbitmq:
    host: RABBITMQ_HOST_IP (Do not use localhost as the clients also use this.)
    user: RABBITMQ_USERNAME
    password: RABBITMQ_USER_PASSWORD
```

If you use SSL, you must enable it and provide the certs. See the [sensu documentation.](http://sensuapp.org/docs/latest/certificates)

Custom check definitions/extentions/mutators/handlers/plugins can be deployed to all masters by placing the scripts into the corresponding directory in ./sensu/files/.
The included check-procs.rb comes from the [sensu-community-plugins](https://github.com/sensu/sensu-community-plugins) as an example only. There is no guarantee that it up-to-date and it should not be used.

If you are not running your redis server locally, set the following in the pillar:
```
sensu:
  redis:
    host: HOSTNAME
    port: PORT
```

``sensu.client``
------------

Configures sensu-client and starts the service.

Check scripts can be deployed to all clients by placing them into ./sensu/files/plugins.

You can use the embedded ruby or installing nagios plugins by setting:
```
sensu:
  client:
    embedded_ruby: true
    nagios_plugins: true
```

To subscribe your clients to the appropriate checks, extend the sensu.client state and override the /etc/sensu/conf.d/client.json file block. You must provide your own method, I am currently using custom set grains associated to the servers's role.

```
include:
  - sensu.client

extend:
  /etc/sensu/conf.d/client.json:
    file.managed:
      - source: salt://your/file/here
```

``sensu.api``
------------

Configures sensu-api and starts the service.

``sensu.uchiwa``
------------

Configures [uchiwa](http://sensuapp.org/docs/latest/dashboards_uchiwa) and starts the service.

Uchiwa can manage multiple Sensu clusters. You can manage them by creating more sites in the pillar. Override the neccesary default values.
