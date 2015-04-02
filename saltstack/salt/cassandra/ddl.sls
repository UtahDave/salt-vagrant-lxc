# Run the DDL
# The DDL is non-destructive. It uses IF NOT EXISTS on all commands.

cassandra-cql:
  file.managed:
    - name: /tmp/salt-ddl.cql
    - source: salt://cassandra/conf/salt-ddl.cql

# /etc/hosts could/should be altered to allow the below IP address to be
# a DNS name instead. Not a high priority right now.

# It is important to understand that the cassandra service starts quickly
# but cassandra does not accept connections for a while. The below cmd.script
# calls a script that will loop 15 times; sleeping 1 second between tries.
# TODO: Cassandra start times may be influenced considerablly by many factors.
#       Therefore, to find a better solution. 
cassandra-run-ddl:
  cmd.script:
    - source: salt://cassandra/ddl-retry.sh
    - shell: /bin/bash
    - timeout: 300
    - require:
      - file: cassandra-cql
  service.running:
    - name: cassandra
    - require:
      - cmd: cassandra-run-ddl
