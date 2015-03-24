base:
  '*':
    - pip
    #- libsodium
  'roles:cassandra*':
    - match: grain
    - cassandra
    - cassandra.driver
