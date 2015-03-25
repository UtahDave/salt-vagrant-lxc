# Run the DDL
# The DDL is non-destructive. It uses IF NOT EXISTS on all commands.

cassandra-cql:
  file.managed:
    - name: /tmp/salt-ddl.cql
    - source: salt://cassandra/conf/salt-ddl.cql

# /etc/hosts could/should be altered to allow the below IP address to be
# a DNS name instead. Not a high priority right now.
cassandra-run-ddl:
  cmd.run:
    - name: |
        cqlsh 192.168.50.11 -u cassandra -p cassandra -f /tmp/salt-ddl.cql
    - shell: /bin/bash
    - timeout: 300
    - require:
      - file: cassandra-cql
  service.running:
    - name: cassandra
    - require:
      - cmd: cassandra-run-ddl
