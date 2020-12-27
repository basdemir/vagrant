VAGRANTFILE_API_VERSION = "2"

$nodes_count=4
$nodes_memory=4096
$nodes_cpus=2
$startingIp=100

def hostPrefix()
  return "rancher-0"
end

$subnet ||= "172.18.8"

def workerIP(num)
  return "#{$subnet}.#{num+$startingIp}"
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.insert_key = false
  # plugin conflict
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  config.vm.box = "bento/ubuntu-20.04"
  (1..$nodes_count).each do |i|
    config.vm.define vm_name = "#{hostPrefix()}%d" % i do |node|
      node.vm.network :private_network, :ip => "#{workerIP(i)}"
      node.vm.hostname = vm_name

      node.vm.provider "virtualbox" do |v|
        if i == 1                       
          v.memory = 6154
          v.cpus = 3
        elsif i == 2                       
          v.memory = 4096
          v.cpus = $nodes_cpus
        else                            
          v.memory = $nodes_memory
          v.cpus = $nodes_cpus
        end                             
      end
      # You can disable above scripts if you use custom VM image which include necessary installations.
      node.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y zsh nano vim git mlocate ldap-utils gnutls-bin ssl-cert tmux net-tools dnsutils

      systemctl stop ufw
      systemctl disable ufw
      SHELL
      node.vm.provision :shell, :path => "vagrantscripts/grubupdate.sh"
      node.vm.provision :shell, :path => "vagrantscripts/bootstrap.sh", :args => "#{workerIP(i)}"
      node.vm.provision :shell, :path => "vagrantscripts/setLocale.sh"
      # Change the vagrant user's shell to use zsh
      node.vm.provision :shell, inline: "chsh -s /usr/bin/zsh vagrant"
      node.vm.provision :shell, :path => "vagrantscripts/shellVimExtras.sh"
      node.vm.provision :shell, :path => "vagrantscripts/shellVimExtras.sh", privileged: false
      node.vm.provision :shell, :path => "vagrantscripts/minimal.sh", :args => ["#{workerIP(i)}", "#$startingIp", "#$nodes_count", "#{$subnet}", "#{hostPrefix()}"]
    end
  end
end
