# Start all cassandra seeds (currently 1) followed by all nodes
# Nodes boostrap off of the seeds in each datacenter, but
# auto_bootstrap is set to false in the cassandra.yaml file, so
# each node can join the cluster at the same time.

cassandra_seeds_startup:
  salt.state:
    - tgt: 'roles:cassandra-seed'
    - tgt_type: grain
    - sls:
      - cassandra.start

cassandra_seed_ddl:
  salt.state:
    - tgt: 'roles:cassandra-seed'
    - tgt_type: grain
    - sls:
      - cassandra.ddl
    - require:
      - salt: cassandra_seeds_startup

cassandra_nodes_startup:
  salt.state:
    - tgt: 'roles:cassandra-node'
    - tgt_type: grain
    - sls: cassandra.start
    - require: 
      - salt: cassandra_seed_ddl

cassandra_cql_runner_install:
  salt.state:
    - tgt: '*'
    - sls: cassandra.add-custom-returners
    - require: 
      - salt: cassandra_nodes_startup

enable_master_job_cache:
  salt.state:
    - tgt: 'master_minion'
    - sls: cassandra.enable-in-master-config
    - require: 
      - salt: cassandra_cql_runner_install
