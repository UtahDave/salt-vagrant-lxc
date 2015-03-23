add-cassandra-repo:
  pkgrepo.managed:
{% if grains['os_family'] == 'RedHat' %}
    - humanname: DataStax Repo for Apache Cassandra
    - name: datastax
    - baseurl: http://rpm.datastax.com/community
    - comments:
      - '#baseurl=http://rpm.datastax.com/community'
    - gpgcheck: 0
{% elif grains['os_family'] == 'Debian' %}
    - name: deb http://debian.datastax.com/community stable main
    - file: /etc/apt/sources.list.d/cassandra.sources.list
    - key_url: http://debian.datastax.com/debian/repo_key
    - refresh_db: True
{% endif %}
    - enabled: true
    - clean_file: True
    #- require_in:
      #- pkg: dsc21
