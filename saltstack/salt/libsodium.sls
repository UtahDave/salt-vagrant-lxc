# Install Oracle Java - 
# ---------------------

# OS agnostic method (tarball install)
# ------------------------------------
# A file (tar, rpm, deb) has to be downloaded in all cases
# Might as well use a method that will work on all 64 bit linux distros.

libsodium-build-essential:
{% if grains['os_family'] == 'RedHat' %}
  yumpkg.group_install:
    - "Development Tools" 
    - "Development Libraries"
{% elif grains['os_family'] == 'Debian' %}
  pkg.installed:
    - name: build-essential
{% endif %}

install-libsodium:
  cmd.run:
    - name: |
        cd /tmp
        wget -O libsodium.tar.gz https://download.libsodium.org/libsodium/releases/LATEST.tar.gz
        tar xzf libsodium.tar.gz -C /usr/src/
        cd /usr/src/libsodium*
        ./configure && make && make install
    - cwd: /tmp
    - shell: /bin/bash
    - timeout: 300
    - reload_modules: true
    - unless: test -x /usr/src/libsodium
    - require:
      - pkg: libsodium-build-essential
