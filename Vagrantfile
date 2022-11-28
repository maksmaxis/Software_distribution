# -*- mode: ruby -*-
# vi: set ft=ruby :
#$script = <<-SHELL
#echo "None do"
#SHELL
Vagrant.configure("2") do |config|

# All servers will run CentOS Stream v.8
    config.vm.box = "centos/stream8"
    #config.vm.box_check_update = true

# Create the rpmbuilder server
  config.vm.define "rpmbuilder" do |rpm|
    rpm.vm.hostname = "rpmbuilder" 
    rpm.vm.network "private_network", ip: "192.168.56.10"
    rpm.vm.network "public_network", bridge: "wlp2s0"
    rpm.vm.network "forwarded_port", guest: 22, host: 8020
    rpm.vm.provider "virtualbox" do |v|
    #v.customize ["modifyvm", :id, "--nic4", "natnetwork"]
    v.name = "rpmbuilder"
    v.memory = "2048"
    v.cpus = 1
  end
    rpm.vm.provision "shell", path: "provision.sh"
  end
end
