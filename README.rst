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

Recommendation::

    LXC containers: 4
    Memory per container: 2G (configured JVM limit. More would be better)
    Disk per container: 20G (depends on how much data you want to throw at Cassandra)

Conclusion::

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
consisting of the following::

    Cluster: 'Test Cluster'
      Datacenter:
        minion1: Cassandra seed node
        minion2: Cassandra node
        minion3: Cassandra node

Make sure each container is running

.. code-block:: bash

    vagrant status

You should see something similar to the following::

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

test.ping should produce the following result. If one or more of the minions
are down (return False) and no errors were reported during provisioning
(vagrant up), use ``vagrant ssh`` to log into each container where the minion
is not running and start the salt-minion service::

    minion1:
        True
    minion3:
        True
    minion2:
        True
    master_minion:
        True

Note that there may be a master_minion running on the master. The master_minion
will be needed to complete this setup. The master_minion will restart the master
after the orchestration step enables the master_job_cache and event_return
configuration parameters in the master config file. 

Once minion1-3 are responding to a test.ping, use Salt Orchestration to start
the Cassandra seeding process for the datacenter. Orchestration guarantees that
the seed (minion1) is started before the nodes that depend on it for seeding DDL
(schema) and data.

Run the cassandra-seeding orchestration SLS file

.. code-block:: bash

    sudo salt-run state.orchestrate orchestration.cassandra-seeding

In a separate shell, log into the Cassandra seed node (minion1) and make sure
each Cassandra node has at least begun the seeding process.

.. code-block:: bash

    vagrant ssh minion1
    sudo nodetool status

You should see something similar to the following. All three entries may not be
immediately displayed, but you should at least see 192.168.50.11 (minion1) and
192.168.50.12 (minion2). If you don't see 192.168.50.13 (minion3), give it a
couple of minutes, 192.168.50.12 is likely blocking it from seeding right away.

The first two letters encode the status. 

Status - U (up) or D (down)
Indicates whether the node is functioning or not.

State - N (normal), L (leaving), J (joining), M (moving)
The state of the node in relation to the cluster.::

    Datacenter: datacenter1
    =======================
    Status=Up/Down
    |/ State=Normal/Leaving/Joining/Moving
    --  Address        Load       Tokens  Owns    Host ID                               Rack
    UN  192.168.50.11  102.42 KB  256     ?       2b0a4b93-25ae-42e7-bcde-8c1d6fcd7045  rack1
    UN  192.168.50.12  60.79 KB   256     ?       ef5df2b0-38d4-4d34-8016-39a13806523e  rack1
    DJ  192.168.50.13  61.15 KB   256     ?       453c4d47-184c-4fd8-bae4-2a74f00be0cd  rack1

Occationally, Cassandra will stacktrace or timeout when nodes are joining the
cluster for the first time (seeding).::

    java.lang.RuntimeException: Error during boostrap: Stream failed

In Cassandra release 2.1.x, only one node can sync DDL/data (seeding) and join
the cluster at a time. If 192.168.50.12 or 192.168.50.13 is not displayed or
fails to join or enter the "UN" (up, normal) state, login to the master and make
sure cassandra is running on each cassandra node. If the service is down and the
node has yet to join the cluster, the seeding process will begin immediately.

.. code-block:: bash

    sudo salt -G 'roles:cassandra*' service.start cassandra

TODO: put the following two steps in the orchestrate file:

Configure the Master Job Cache and Event Return to use the cassandra returner

.. code-block:: bash

    salt-run state.sls cassandra.enable-in-master-config

Restart the master

.. code-block:: bash

    service salt-master restart
