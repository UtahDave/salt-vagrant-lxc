# This state assumes python is installed.
# TODO: ensure the correct version of python is installed
#       Perhaps RedHat and Debian detection is sufficient.
python:
  pkg.installed

wget:
  pkg.installed

install-pip:
  cmd.run:
    - name: |
        cd /tmp
        wget https://bootstrap.pypa.io/get-pip.py
        python get-pip.py
    - shell: /bin/bash
    - timeout: 300
    - unless: pip -V
    - reload_modules: true
    - require:
      - pkg: wget
      - pkg: python
