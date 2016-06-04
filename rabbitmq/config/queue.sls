{% from "rabbitmq/macros.jinja" import settings with context %}

{% for name, queue in salt["pillar.get"]("rabbitmq:queue", {}).items() %}
  {% from "rabbitmq/default.jinja" import defaults with context %}
  {% set data = settings(queue, defaults.queue)|load_yaml %}
rabbitmq_queue_{{ name }}:
  cmd.run:
    - name: rabbitmqadmin --vhost={{ data.vhost }} declare queue name={{ name }} auto_delete={{ data.auto_delete|lower }} durable={{ data.durable|lower }} arguments='{{ data.arguments }}'
    - require:
      - service: rabbitmq-server
{% endfor %}
