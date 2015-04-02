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

.. code-block:: text

    LXC containers: 4
    Memory per container: 2G (configured JVM limit. More would be better)
    Disk per container: 20G (depends on how much data you want to throw at Cassandra)

Conclusion:

.. code-block:: text

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

Make sure each container is running

.. code-block:: bash

    vagrant status

You should see something similar to the following:

.. note::

    master                    running (lxc)
    minion1                   running (lxc)
    minion2                   running (lxc)
    minion3                   running (lxc)

The Salt Minions (minion1-3) will point to the Salt Master (master) and the
Cassandra nodes (minion2-3) seed from the Cassandra seed node (minion1). You
can then run the following commands to log into the Salt Master and begin
using Salt.

.. code-block:: bash

    vagrant ssh master
    sudo salt '*' test.ping

test.ping should produce the following result:

.. node::

    minion1:
        True
    minion3:
        True
    minion2:
        True
    master_minion:
        True

Note that there may be a master_minion running on the master. The master_minion
will not be needed to complete this setup. Once minion1-3 are responding to a
test.ping, use Salt Orchestration to start the Cassandra seeding process for the
datacenter. Orchestration guarantees that the seed (minion1) is started before
the nodes that depend on it for seeding DDL and data.

Run the cassandra-seeding orchestration SLS file

.. code-block:: bash

    sudo salt-run state.orchestrate orchestration.cassandra-seeding

In a separate shell, log into the Cassandra seed node (minion1) and make sure
each Cassandra node has at least begun the seeding process.

.. code-block:: bash

    vagrant ssh minion1
    sudo nodetool status

You should see something similar to the following:

.. note::

    Datacenter: datacenter1
    =======================
    Status=Up/Down
    \|/ State=Normal/Leaving/Joining/Moving
    --  Address        Load       Tokens  Owns    Host ID                               Rack
    UN  192.168.50.11  101.39 KB  256     ?       2b604b31-1842-4398-bd45-d01ef025f6fd  rack1
    UN  192.168.50.12  108.45 KB  256     ?       3ee342c5-23a5-45cf-b545-71c66ee400ea  rack1
    UN  192.168.50.13  103 KB     256     ?       87789a2c-c96b-4a5f-86b6-d9c90348fb9c  rack1

Configure the Master Job Cache and Event Return to use the cassandra returner

.. code-block:: bash

    salt-run state.sls cassandra.enable-in-master-config

Restart the master

.. code-block:: bash

    service salt-master restart
