{% if grains['os_family'] == 'RedHat' %}
  {% set baseDir = '/etc/cassandra/conf' %}
{% elif grains['os_family'] == 'Debian' %}
  {% set baseDir = '/etc/cassandra' %}
{% endif %}

include:
  - java
  - firewall
  - datastax-repo

# Install Cassandra
# dsc21 
# cassandra21-tools (optional)

install-cassandra:
  pkg.installed:
    - name: dsc21
    - skip_verify: True
    - skip_suggestions: True
    - refresh: True
    - hold: False
    - require:
      - sls: java
      - sls: firewall
      - sls: datastax-repo

# Stop cassandra in preparation for configuration
stop-cassandra:
  service.dead:
    - name: cassandra
    - enable: True
    - require:
      - pkg: install-cassandra

# Configure Cassandra Nodes
# --------------------------
# Cassandra datacenter/cluster configuration at a glance:
#
# A cluster consists of one or more datacenters. And datacenters consist of
# one or more nodes. The following is a single data center config. 
# The Datacenter name "Test Cluster" would likely be"DC1" or something like 
# that if we had multiple data centers configured in 
# cassandra-topology.properties.
#
# Cluster: 'Test Cluster'
#   Datacenter (a.k.a. Replication Group): 
#     Node: minion1 - seed
#     Node: minion2
#     Node: minion3

# Make master_minion the seed node for the Test Cluster datacenter 
# Copy the following...
#   /etc/cassandra/conf/cassandra.yaml
#   /etc/cassandra/conf/cassandra-env.yaml
# ...to all nodes.
#
# Note: If the nodes in the cluster are identical in terms of disk layout, 
# shared libraries, and so on, you can use the same copy of the 
# cassandra.yaml file on all of them.
#
# TODO: Apparently VMs may require the listen_address be set even if DNS 
#       works.

cassandra-config:
  file.managed:
    - name: {{baseDir}}/cassandra.yaml
    - source: salt://cassandra/cassandra.yaml
    - require:
      - pkg: install-cassandra

cassandra-env-config:
  file.managed:
    - name: {{baseDir}}/cassandra-env.sh
    - source: salt://cassandra/cassandra-env.sh
    - require:
      - pkg: install-cassandra

# Clear the data directory
delete-cassandra-data:
  file.absent:
    - name: /var/lib/cassandra/data
    - require:
      - pkg: install-cassandra

# Recreate the data directory
create-cassandra-data:
  file.directory:
    - name: /var/lib/cassandra/data
    - user: cassandra
    - group: cassandra 
    - mode: 0755
    - require:
        - file: delete-cassandra-data
