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
{% endfor %}

rabbitmq_federation:
  cmd.run:
    - name: rabbitmq-plugins enable rabbitmq_federation && service rabbitmq-server restart
    - unless: rabbitmq-plugins list -e -m | grep -w "rabbitmq_federation"
    - require:
      - rabbitmq_plugin: rabbitmq_management

install_rabbit_management:
  cmd.run:
    - name: curl -k -L http://localhost:15672/cli/rabbitmqadmin -o /usr/local/bin/rabbitmqadmin
    - unless: test -f /usr/local/bin/rabbitmqadmin
    - require:
      - cmd: rabbitmq_federation

chmod_rabbit_management:
  file.managed:
  - name: /usr/local/bin/rabbitmqadmin
  - user: root
  - group: root
  - mode: 755
  - require:
    - cmd: install_rabbit_management
