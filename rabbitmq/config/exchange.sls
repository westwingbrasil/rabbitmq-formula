{% from "rabbitmq/macros.jinja" import settings with context %}

{% for name, exchange in salt["pillar.get"]("rabbitmq:exchange", {}).items() %}
  {% from "rabbitmq/default.jinja" import defaults with context %}
  {% set data = settings(exchange, defaults.exchange)|load_yaml %}
rabbitmq_exchange_{{ name }}:
  cmd.run:
    - name: rabbitmqadmin --vhost={{ data.vhost }} declare exchange name={{ name }} type={{ data.type }}
    - require:
      - service: rabbitmq-server
{% endfor %}