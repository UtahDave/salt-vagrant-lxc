# Install the python module to test
include:
  - cassandra.driver

#'/srv/salt/_returners/cassandra_cql_return.py':
'/usr/lib/python2.7/dist-packages/salt/returners/cassandra_cql_return.py':
  file.managed:
    - source: salt://cassandra/_returners/cassandra_cql_return.py
    - makedirs: True
    - reload_modules: True
    - require:
      - pip: cassandra-driver
