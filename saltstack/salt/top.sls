base:
  #'*':
    #- libsodium
  'roles:cassandra*':
    - match: grain
    - cassandra-community-edition
