# Install the python module to test
include:
  - pip

cassandra-driver:
  pip.installed:
    - name: cassandra-driver
    - require:
      - sls: pip
