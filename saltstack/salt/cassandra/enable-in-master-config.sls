cassandra-run-ddl:
  cmd.run:
    - name: | 
        sed -i.bak s/^#master_job_cache/master_job_cache/g /etc/salt/master
        sed -i.bak s/^#event_return/event_return/g /etc/salt/master
    - shell: /bin/bash
    - timeout: 300
  service.running:
    - name: salt-master 
    - reload: True
    - require:
      - cmd: cassandra-run-ddl
