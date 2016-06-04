{% from "rabbitmq/macros.jinja" import settings with context %}

{% for name in salt["pillar.get"]("rabbitmq:vhost", []) %}
rabbitmq_vhost_{{ name }}:
  cmd.run:
    - name: rabbitmqadmin declare vhost name={{ name }}
    - require:
      - service: rabbitmq-server
{% endfor %}

rabbitmq_user_guest:
  cmd.run:
    - name: rabbitmqadmin declare user name=guest password=guest tags=administrator
    - require:
      - service: rabbitmq-server
{% for name in salt["pillar.get"]("rabbitmq:vhost", []) %}
rabbitmq_user_guest_vhost_{{name}}:
  cmd.run:
    - name: rabbitmqadmin declare permission vhost={{ name }} user=guest configure=.* write=.* read=.*
    - require:
      - service: rabbitmq-server
{% endfor %}

{% for name, user in salt["pillar.get"]("rabbitmq:user", {}).items() %}
  {% from "rabbitmq/default.jinja" import defaults with context %}
  {% set data = settings(user, defaults.user)|load_yaml %}
rabbitmq_user_{{ name }}:
  cmd.run:
    - name: rabbitmqadmin declare user name={{ name }} password={{ data.password }} tags={{ data.tags }}
    - require:
      - service: rabbitmq-server
  {% for helper in data.perms %}
    {% for vhost, permission in helper.items() %}
rabbitmq_user_{{ name }}_vhost_{{vhost}}:
  cmd.run:
    - name: rabbitmqadmin declare permission vhost={{ vhost }} user={{ name }} configure={{ permission[0] }} write={{ permission[1] }} read={{ permission[2] }}
    - require:
      - service: rabbitmq-server
    {% endfor %}
  {% endfor %}
{% endfor %}