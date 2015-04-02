base:
  '*':
    - pip
    - cassandra.driver
  'roles:cassandra*':
    - match: grain
    - cassandra
