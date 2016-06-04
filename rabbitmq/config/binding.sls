{% from "rabbitmq/macros.jinja" import settings with context %}

{% for name, binding in salt["pillar.get"]("rabbitmq:binding", {}).items() %}
  {% from "rabbitmq/default.jinja" import defaults with context %}
  {% set data = settings(binding, defaults.binding)|load_yaml %}
rabbitmq_binding_{{ name }}:
  cmd.run:
    - name: rabbitmqadmin --vhost={{ data.vhost }} declare binding source={{ data.source }} destination={{ data.destination }} routing_key={{ data.routing_key }} destination_type={{ data.destination_type }}
    - require:
      - service: rabbitmq-server
{% endfor %}
