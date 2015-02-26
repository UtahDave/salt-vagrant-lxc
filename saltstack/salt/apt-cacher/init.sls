apt-cacher-config:
  file.managed:
    - name: /etc/apt/apt.conf.d/apt-cacher.conf
    - source: salt://apt-cacher/apt-cacher.conf
    - user: root
    - group: root
    - mode: 664
