# This state assumes python is installed.
# TODO: ensure the correct version of python is installed
#       Perhaps RedHat and Debian detection is sufficient.

required_pkgs:
  pkg.installed:
    - pkgs:
      - python
      - python-pip
      - wget
