# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define :master do |master_config|
    #master_config.vm.box = "hashicorp/precise64"
    #master_config.vm.box = "fgrehm/precise64-lxc"
    master_config.vm.box = "fgrehm/trusty64-lxc"
    master_config.vm.host_name = 'saltmaster.local'
    #master_config.vm.network "private_network", ip: "192.168.50.10"
    master_config.vm.network "private_network", ip: "192.168.50.10", lxc__bridge_name: 'virbr0'
    master_config.vm.synced_folder "saltstack/salt/", "/srv/salt"
    master_config.vm.synced_folder "saltstack/pillar/", "/srv/pillar"
    master_config.vm.synced_folder "saltstack/reactor/", "/srv/reactor"
    #master_config.vm.provision "file",
    #    source: "./saltstack/salt/apt-cacher/apt-cacher.conf",
    #    destination: "/home/vagrant/apt-cacher.conf"
    #master_config.vm.provision "shell",
    #        inline: "cp /home/vagrant/apt-cacher.conf /etc/apt/apt.conf.d/apt-cacher.conf"

    master_config.vm.provision :salt do |salt|
      salt.master_config = "saltstack/etc/master"
      salt.master_key = "saltstack/keys/master.pem"
      salt.master_pub = "saltstack/keys/master.pub"
      salt.seed_master = {
                          "master_minion" => "saltstack/keys/master_minion.pub",
                          "minion1"       => "saltstack/keys/minion1.pub",
                          "minion2"       => "saltstack/keys/minion2.pub",
                          "minion3"       => "saltstack/keys/minion3.pub"
                         }
      #salt.install_type = "git"
      #salt.install_args = '2014.7'
      salt.install_type = "git"
      salt.install_args = '2015.2'
      salt.install_master = true
      #salt.no_minion = true
      salt.minion_config = "saltstack/etc/master_minion"
      salt.minion_key = "saltstack/keys/master_minion.pem"
      salt.minion_pub = "saltstack/keys/master_minion.pub"
      salt.verbose = true
    end
  end

  config.vm.define :minion1 do |minion_config|
    #minion_config.vm.box = "hashicorp/precise64"
    #minion_config.vm.box = "fgrehm/precise64-lxc"
    minion_config.vm.box = "fgrehm/trusty64-lxc"
    minion_config.vm.host_name = 'saltminion1.local'
    #minion_config.vm.network "private_network", ip: "192.168.50.11"
    minion_config.vm.network "private_network", ip: "192.168.50.11", lxc__bridge_name: 'virbr0'
    #minion_config.vm.provision "file",
    #    source: "./saltstack/salt/apt-cacher/apt-cacher.conf",
    #    destination: "~/apt-cacher.conf"
    #minion_config.vm.provision "shell",
    #        inline: "cp /home/vagrant/apt-cacher.conf /etc/apt/apt.conf.d/apt-cacher.conf"

    minion_config.vm.provision :salt do |salt|
      salt.minion_config = "saltstack/etc/minion1"
      salt.minion_key = "saltstack/keys/minion1.pem"
      salt.minion_pub = "saltstack/keys/minion1.pub"
      #salt.install_type = "git"
      #salt.install_args = '2014.7'
      salt.install_type = "git"
      salt.install_args = '2015.2'
      salt.verbose = true
    end
  end

  config.vm.define :minion2 do |minion_config|
    #minion_config.vm.box = "hashicorp/precise64"
    #minion_config.vm.box = "fgrehm/precise64-lxc"
    minion_config.vm.box = "fgrehm/trusty64-lxc"
    # The following line can be uncommented to use Centos
    # instead of Ubuntu.
    # Comment out the above line as well
    #minion_config.vm.box = "chef/centos-6.5"
    minion_config.vm.host_name = 'saltminion2.local'
    #minion_config.vm.network "private_network", ip: "192.168.50.12"
    minion_config.vm.network "private_network", ip: "192.168.50.12", lxc__bridge_name: 'virbr0'
    #minion_config.vm.provision "file",
        #source: "./saltstack/salt/apt-cacher/apt-cacher.conf",
        #destination: "~/apt-cacher.conf"
    #minion_config.vm.provision "shell",
            #inline: "cp /home/vagrant/apt-cacher.conf /etc/apt/apt.conf.d/apt-cacher.conf"

    minion_config.vm.provision :salt do |salt|
      salt.minion_config = "saltstack/etc/minion2"
      salt.minion_key = "saltstack/keys/minion2.pem"
      salt.minion_pub = "saltstack/keys/minion2.pub"
      #salt.install_type = "git"
      #salt.install_args = '2014.7'
      salt.install_type = "git"
      salt.install_args = '2015.2'
      salt.verbose = true
    end
  end

  config.vm.define :minion3 do |minion_config|
    #minion_config.vm.box = "hashicorp/precise64"
    #minion_config.vm.box = "fgrehm/centos-6-64-lxc"
    #minion_config.vm.box = "fgrehm/precise64-lxc"
    minion_config.vm.box = "fgrehm/trusty64-lxc"
    # The following line can be uncommented to use Centos
    # instead of Ubuntu.
    # Comment out the above line as well
    #minion_config.vm.box = "chef/centos-6.5"
    minion_config.vm.host_name = 'saltminion3.local'
    #minion_config.vm.network "private_network", ip: "192.168.50.12"
    minion_config.vm.network "private_network", ip: "192.168.50.13", lxc__bridge_name: 'virbr0'
    #minion_config.vm.provision "file",
        #source: "./saltstack/salt/apt-cacher/apt-cacher.conf",
        #destination: "~/apt-cacher.conf"
    #minion_config.vm.provision "shell",
            #inline: "cp /home/vagrant/apt-cacher.conf /etc/apt/apt.conf.d/apt-cacher.conf"

    minion_config.vm.provision :salt do |salt|
      salt.minion_config = "saltstack/etc/minion3"
      salt.minion_key = "saltstack/keys/minion3.pem"
      salt.minion_pub = "saltstack/keys/minion3.pub"
      #salt.install_type = "git"
      #salt.install_args = '2014.7'
      salt.install_type = "git"
      salt.install_args = '2015.2'
      salt.verbose = true
    end
  end

end
