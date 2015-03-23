# Start all cassandra seeds followed by all nodes
# Nodes boostrap off of the seeds in each datacenter
cassandra_seeds_startup:
  salt.state:
    - tgt: 'roles:cassandra-seed'
    - tgt_type: grain
    - sls: cassandra-start

cassandra_nodes_startup:
  salt.state:
    - tgt: 'roles:cassandra-node'
    - tgt_type: compound 
    - sls: cassandra-start
    - require: 
      - salt: cassandra_seeds_startup
