# Install the python module to test
include:
  - cassandra.driver

/srv/salt/_modules/cassandra_cql.py
  file.managed:
    - source: salt://cassandra/_modules/cassandra_cql.py
    - makedirs: True
    - require:
      - pip: cassandra.driver
