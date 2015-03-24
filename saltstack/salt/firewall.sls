# Simplify things by disabling the firewall
# OS detection is just an optimization. This state will do a best effort
# to stop the most common firewalls on many linux distros.
#
# TODO: Use the following documentation to open all necessary ports:
# http://www.datastax.com/documentation/cassandra/2.1/cassandra/security/secureFireWall_r.html
#
# TODO: use Jinja to disable firewalld, iptables, or ufw depending on OS
firewalld:
  service.dead:
    - enable: False

iptables:
  service.dead:
    - enable: False

ufw:
  service.dead:
    - enable: False
