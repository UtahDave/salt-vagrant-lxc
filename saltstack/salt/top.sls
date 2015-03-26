base:
  '*':
    - pip
    - cassandra.driver
    #- libsodium
  'roles:cassandra*':
    - match: grain
    - cassandra
    - cassandra.start
  'roles:cassandra-seed':
    - cassandra.ddl
