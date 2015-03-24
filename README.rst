================
Salt Vagrant LXC
================

A Salt Setup using Vagrant and LXC


Instructions
============

Run the following commands in a terminal. Vagrant, the Vagrant LXC plugin and
your hosts lxc packages must already be installed.

.. code-block:: bash

    vagrant plugin install vagrant-lxc

.. code-block:: bash

    git clone https://github.com/UtahDave/salt-vagrant-lxc.git
    cd salt-vagrant-lxc
    vagrant up --provider lxc


This will download an Ubuntu lxc container and create four linux containers for
you. One will be a Salt Master named `master` and the others will be Salt
Minions named `minion1`, `minion2`, and `minion3` containing a Cassandra cluster
consisting of the following:

Cluster: 'Test Cluster'
  Datacenter (only one, thus not named): 
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
minion is responding to a ping and that every Cassandra node has at least begun 
the seeding process.

.. code-block:: bash

    sudo salt '*' test.ping
    sudo salt-run state.orchestrate orchestration.cassandra-seeding
