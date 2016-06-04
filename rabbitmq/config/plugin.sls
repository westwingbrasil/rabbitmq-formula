{% for name, plugin in salt["pillar.get"]("rabbitmq:plugin", {}).items() %}
{{ name }}:
  rabbitmq_plugin:
    {% for value in plugin %}
    - {{ value }}
    {% endfor %}
    - runas: root
    - require:
      - pkg: rabbitmq-server
      - file: rabbitmq_binary_tool_plugins
      {% if loop.index0 != 0 %}
      - rabbitmq_plugin: {{ salt["pillar.get"]("rabbitmq:plugin", {}).items()[loop.index0 - 1][0] }}
      {% endif %}
    {% if loop.last %}
    - watch_in:
      - service: rabbitmq-server
    {% endif %}
{% endfor %}

install_rabbit_management:
  cmd.run:
    - name: curl -k -L http://localhost:15672/cli/rabbitmqadmin -o /usr/local/bin/rabbitmqadmin
    - unless: test -f /usr/local/bin/rabbitmqadmin
    - require:
      - rabbitmq_plugin: {{ salt["pillar.get"]("rabbitmq:plugin", {}).items()[salt["pillar.get"]("rabbitmq:plugin", {}).items()|length() - 1][0] }}

chmod_rabbit_management:
  file.managed:
  - name: /usr/local/bin/rabbitmqadmin
  - user: root
  - group: root
  - mode: 755
  - require:
    - cmd: install_rabbit_management
