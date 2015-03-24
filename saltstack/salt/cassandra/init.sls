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

# TODO:
# salt -G 'roles:cassandra-seed' cassandra.create_keyspace salt
# salt -G 'roles:cassandra-seed' cassandra.create_user salt
# salt -G 'roles:cassandra-seed' cassandra.grant_permission salt salt
#
# Convert the following schema to CQL.
#
#CREATE DATABASE  `salt`
  #DEFAULT CHARACTER SET utf8
  #DEFAULT COLLATE utf8_general_ci;
#
#USE `salt`;
#
#--
#-- Table structure for table `jids`
#--
#
#DROP TABLE IF EXISTS `jids`;
#CREATE TABLE `jids` (
  #`jid` varchar(255) NOT NULL,
  #`load` mediumtext NOT NULL,
  #UNIQUE KEY `jid` (`jid`)
#) ENGINE=InnoDB DEFAULT CHARSET=utf8;
#
#--
#-- Table structure for table `salt_returns`
#--
#
#DROP TABLE IF EXISTS `salt_returns`;
#CREATE TABLE `salt_returns` (
  #`fun` varchar(50) NOT NULL,
  #`jid` varchar(255) NOT NULL,
  #`return` mediumtext NOT NULL,
  #`id` varchar(255) NOT NULL,
  #`success` varchar(10) NOT NULL,
  #`full_ret` mediumtext NOT NULL,
  #`alter_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  #KEY `id` (`id`),
  #KEY `jid` (`jid`),
  #KEY `fun` (`fun`)
#) ENGINE=InnoDB DEFAULT CHARSET=utf8;
#
#--
#-- Table structure for table `salt_events`
#--
#
#DROP TABLE IF EXISTS `salt_events`;
#CREATE TABLE `salt_events` (
#`id` BIGINT NOT NULL AUTO_INCREMENT,
#`tag` varchar(255) NOT NULL,
#`data` varchar(1024) NOT NULL,
#`alter_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
#`master_id` varchar(255) NOT NULL,
#PRIMARY KEY (`id`),
#KEY `tag` (`tag`)
#) ENGINE=InnoDB DEFAULT CHARSET=utf8;
