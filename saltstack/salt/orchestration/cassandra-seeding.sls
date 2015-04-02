# Start all cassandra seeds followed by all nodes
# Nodes boostrap off of the seeds in each datacenter
#
# Each VM in the Vagrantfile is using an inline shell
# call to run the cassandra-start state as soon as salt
# is installed.

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
      - salt: cassandra_seeds_startup

cassandra_cql_runner_install:
  salt.state:
    - tgt: '*'
    - sls: cassandra.add-custom-returners
    - require: 
      - salt: cassandra_nodes_startup

enable_master_job_cache:
  salt.state:
    - tgt: 'master'
    - sls: cassandra.enable-in-master-config
    - require: 
      - salt: cassandra_cql_runner_install
