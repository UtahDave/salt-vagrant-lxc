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

{% if grains['os_family'] == 'RedHat' %}
  {% set baseDir = '/etc/cassandra/conf' %}
{% elif grains['os_family'] == 'Debian' %}
  {% set baseDir = '/etc/cassandra' %}
{% endif %}

include:
  - datastax-repo
  - firewall
  - java

# Install Cassandra
# dsc21 
# cassandra21-tools (optional)

dsc21:
  pkg.installed:
    - skip_verify: True
    - skip_suggestions: True
    - refresh: True
    - hold: False
    - require:
      - sls: java
      - sls: firewall
      - sls: datastax-repo
  service.dead:
    - name: cassandra
    - enable: True
    - require:
      - pkg: dsc21

dsc21_yaml_config:
  file.managed:
    - name: {{baseDir}}/cassandra.yaml
    - source: salt://cassandra/conf/cassandra.yaml
    - require:
      - pkg: dsc21 

dsc21_env_config:
  file.managed:
    - name: {{baseDir}}/cassandra-env.sh
    - source: salt://cassandra/conf/cassandra-env.sh
    - require:
      - pkg: dsc21

dsc21_delete_data_directory:
  file.absent:
    - name: /var/lib/cassandra/data
    - require:
      - pkg: dsc21

dsc21_create_data_directory:
  file.directory:
    - name: /var/lib/cassandra/data
    - user: cassandra
    - group: cassandra 
    - mode: 0755
    - require:
        - file: dsc21_delete_data_directory

# TODO: Figure out how to install the below schema:
# Using salt.modules.cassandra_cql (does not support table creation):
# salt -G 'roles:cassandra-seed' cassandra.create_keyspace salt
# salt -G 'roles:cassandra-seed' cassandra.create_user salt
# salt -G 'roles:cassandra-seed' cassandra.grant_permission salt salt
#
#
# CREATE KEYSPACE IF NOT EXISTS salt 
#            WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 1};
#
# CREATE USER IF NOT EXISTS salt WITH PASSWORD 'salt' NOSUPERUSER;
#
# GRANT ALL ON KEYSPACE salt TO salt;
#
# USE salt;
#
# CREATE KEYSPACE IF NOT EXISTS salt WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};
#
# CREATE TABLE IF NOT EXISTS salt.salt_returns (
#     jid text PRIMARY KEY,
#     alter_time timestamp,
#     full_ret text,
#     fun text,
#     id text,
#     return text,
#     success text
# );
# CREATE INDEX IF NOT EXISTS fun ON salt.salt_returns (fun);
# CREATE INDEX IF NOT EXISTS id ON salt.salt_returns (id);
#
# CREATE TABLE IF NOT EXISTS salt.jid (
#     jid text PRIMARY KEY,
#     load text
# );
#
# CREATE TABLE IF NOT EXISTS salt.salt_events (
#     id timeuuid PRIMARY KEY,
#     alter_time timestamp,
#     data text,
#     master_id text,
#     tag text
# );
# CREATE INDEX IF NOT EXISTS tag ON salt.salt_events (tag);
