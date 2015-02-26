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
Minions named `minion1`, `minion2`, and `minion3`.  The Salt Minions will point
to the Salt Master. You can then run the following commands to log into the
Salt Master and begin using Salt.

.. code-block:: bash

    vagrant ssh master
    sudo salt \* test.ping
