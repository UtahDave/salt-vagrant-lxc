================
Salt Vagrant LXC
================

A Salt + Cassandra Setup using Vagrant and LXC

Hardware Recommendations
========================

LXC containers are generally limited by the ulimit/cgroup resources settings of the
host, but are configurable per instance.

The host managing the LXC containers must have sufficient resources (mem, disk)
to allow for a Salt + Cassandra cluster. The following is the minimum recommended
host resource allocation:

LXC containers: 4
Memory per container: 2G (configured JVM limit. More would be better)
Disk per container: 20G (depends on how much data you want to throw at Cassandra)

Conclusion:
Min memory available on LXC host: 4 * 2G = 8G
Min disk available on LXC host: 4 * 20G = 80G


Instructions
============

Run the following commands in a terminal. Vagrant, the Vagrant LXC plugin and
your hosts lxc packages must already be installed.

.. code-block:: bash

    vagrant plugin install vagrant-lxc

.. code-block:: bash

    git clone https://github.com/ckochenower/salt-vagrant-lxc.git -b cassandra
    cd salt-vagrant-lxc
    vagrant up --provider=lxc


This will download an Ubuntu lxc container and create four linux containers for
you. One will be a Salt Master named `master` and the others will be Salt
Minions named `minion1`, `minion2`, and `minion3` containing a Cassandra cluster
consisting of the following:

.. code-block:: txt

    Cluster: 'Test Cluster'
      Datacenter:
        minion1: Cassandra seed node
        minion2: Cassandra node
        minion3: Cassandra node

The Salt Minions will point to the Salt Master and the Cassandra nodes will point
to the Cassandra seed node. You can then run the following commands to log into 
the Salt Master and begin using Salt.

.. code-block:: bash

    vagrant ssh master
    sudo salt \* test.ping

Run the following commands while logged into the Salt master to make sure each 
minion is responding to a ping.

.. code-block:: bash

    sudo salt '*' test.ping
    sudo salt-run state.orchestrate orchestration.cassandra-seeding

Log into the Cassandra seed node and make sure each Cassandra node has at least begun 
the seeding process.

.. code-block:: bash

    vagrant ssh minion1
    sudo nodetool status
