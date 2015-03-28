# Install the python module to test
include:
  - cassandra.driver

#'/srv/salt/_modules/cassandra_cql.py':
# Just install it as if it came with the bootstrapped version of salt
'/usr/lib/python2.7/dist-packages/salt/modules/cassandra_cql.py':
  file.managed:
    - source: salt://cassandra/_modules/cassandra_cql.py
    - makedirs: True
    - reload_modules: True
    - require:
      - pip: cassandra-driver
