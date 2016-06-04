/etc/rabbitmq/rabbitmq.config:
  file.managed:
    - source: salt://rabbitmq/rabbitmq/config/files/rabbitmq.config
    - require:
        - pkg: rabbitmq-server

/etc/rabbitmq/ssl:
  file.recurse:
    - source: salt://rabbitmq/rabbitmq/config/files/ssl
    - makedirs: True
