Vagrant.configure("2") do |config|
    config.ssh.insert_key = false
    config.ssh.forward_agent = true

    check_guest_additions = false
    functional_vboxsf = false

    config.vm.box = "bento/ubuntu-22.04"

    config.vm.define :deployvm do |machine|
      machine.vm.network :private_network, ip: "192.168.56.10"
      machine.vm.hostname = "deployvm"
      machine.vm.provider "virtualbox" do |v|
          v.name = "deployvm"
          v.memory = 2048
          v.cpus = 4
      end

      machine.vm.provision "ansible" do |ansible|
        ansible.playbook = "ansible/playbook.yml"
        ansible.inventory_path = "ansible/inventory"
        ansible.raw_ssh_args = "-o ForwardAgent=yes -o ConnectionAttempts=20 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
        ansible.verbose = false
        ansible.limit = "all"
      end
    end
end
