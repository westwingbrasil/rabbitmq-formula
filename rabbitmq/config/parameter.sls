{% from "rabbitmq/macros.jinja" import settings with context %}

{% for name, parameter in salt["pillar.get"]("rabbitmq:parameter", {}).items() %}
  {% from "rabbitmq/default.jinja" import defaults with context %}
  {% set data = settings(parameter, defaults.parameter)|load_yaml %}
rabbitmq_parameter_{{ name }}:
  cmd.run:
    - name: rabbitmqadmin --vhost={{ data.vhost }} declare parameter component={{ data.component }} name={{ name }} value='{{ data.value }}'
    - require:
      - service: rabbitmq-server
{% endfor %}