base:
  '*':
    - pip
    #- libsodium
  'roles:cassandra*':
    - match: grain
    - cassandra
    - cassandra.driver
    - cassandra.start
  'roles:cassandra-seed':
    - cassandra.ddl
