# Install the python module to test
include:
  - cassandra.driver

'/srv/salt/_returners/cassandra_cql_return.py':
  file.managed:
    - source: salt://cassandra/_returners/cassandra_cql_return.py
    - makedirs: True
    - require:
      - pip: cassandra-driver
