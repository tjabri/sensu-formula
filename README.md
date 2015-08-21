sensu-formula
================

A saltstack formula to install and configure the open source monitoring framework, [Sensu](http://sensuapp.org/).

>Note:
See the full [Salt Formulas installation and usage instructions](http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html).

Sensu can be configured/scaled with the individual states installed on multiple servers. All states are configured via the pillar file. Sane defaults are set in pillar_map.jinja and can be over-written in the pillar.

>Note:
This formula only manages Sensu!! You are responsible for installing/configuring RabbitMQ and Redis as appropriate.

>Compatibility:
Sensu Client should be working on Ubuntu, CentOS and Windows.
Sensu Server, API and Uchiwa should be working on Ubuntu and CentOS.

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

Backward incompatible changes
=============================

2015-04-15
----------

The default ``sensu:rabbitmq:port`` value is now 5672 (which is the default port of RabbitMQ) instead of 5671.

* If you happened to have used the default previous value of 5671, you should now set it in your pillar file or change your RabbitMQ configuration.
* If you overrode the previous default value of 5671 with 5672, you can now safely remove it.
* If you set up something else instead, you don't have to change anything :)


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

Custom check definitions/extentions/mutators/handlers/plugins can be deployed to all Sensu servers by placing the scripts into the corresponding directory in ./sensu/files/.

The included check-procs.rb comes from the [sensu-community-plugins](https://github.com/sensu/sensu-community-plugins) as an example only. There is no guarantee that it up-to-date and it should not be used.

If you are not running your redis server locally, set the following in the pillar:
```
sensu:
  redis:
    host: HOSTNAME
    port: PORT
```

If you are adding handlers which have additional gem dependencies, i.e the [mailer](https://github.com/sensu/sensu-community-plugins/blob/master/handlers/notification/mailer.rb) handler. You can add them to the pillar data and they will be installed on your Sensu servers.
```
sensu:
  server:
    install_gems:
      - mail
      - timeout
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

To subscribe your clients to the appropriate checks, you can update the `sensu` pillar with the required subscriptions.  You can also override the client address to another interface or change the name of the client.  In addition, you can also enable Sensu's safe mode (highly recommended, off by default).

```
sensu:
  client:
    name: {{ grains['sensu_id'] }}
    address: {{ grains['ip4_interfaces']['eth0'][0] }}
    subscriptions: ['linux', 'compute']
```

If you are adding plugins/checks which have additional gem dependencies. You can add them to the pillar data and they will be installed on your Sensu clients.
```
sensu:
  client:
    install_gems:
      - libxml-xmlrpc
```


``sensu.api``
------------

Configures sensu-api and starts the service.

``sensu.uchiwa``
------------

Configures [uchiwa](http://sensuapp.org/docs/latest/dashboards_uchiwa) and starts the service.

Uchiwa can manage multiple Sensu clusters. You can manage them by creating more sites in the pillar. Override the neccesary default values.
