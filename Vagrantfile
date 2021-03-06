Vagrant.configure("2") do |config|
    # Ubuntu 16.04
    config.vm.box = "ubuntu/xenial64"
    
    config.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--audio", "none"]
    end
  
    # LB for master nodes, must be at the top
    config.vm.define "lb-0" do |c|
        c.vm.hostname = "lb-0"
        c.vm.network "private_network", ip: "192.168.199.40"
  
        c.vm.provision :shell, :path => "scripts/vagrant-setup-haproxy.bash"
  
        c.vm.provider "virtualbox" do |vb|
          vb.memory = 256
          vb.cpus = 1
        end
    end
  
    # Master
    (0..2).each do |n|
      config.vm.define "master-#{n}" do |c|
          c.vm.hostname = "master-#{n}"
          c.vm.network "private_network", ip: "192.168.199.1#{n}"
  
          c.vm.provision :shell, :path => "scripts/vagrant-setup-hosts-file.bash"
          c.vm.provision :shell, :path => "scripts/vagrant-setup-kubernetes.bash"
          c.vm.provision :shell, :path => "scripts/vagrant-setup-etcd.bash"

      end
    end
  
    # Worker
    (0..2).each do |n|
      config.vm.define "worker-#{n}" do |c|
          c.vm.hostname = "worker-#{n}"
          c.vm.network "private_network", ip: "192.168.199.2#{n}"

          c.vm.provision :shell, :path => "scripts/vagrant-setup-hosts-file.bash"
          c.vm.provision :shell, :path => "scripts/vagrant-setup-kubernetes.bash"  
      end
    end
  

    # NFS server for persistent volume provisioning
    config.vm.define "nfsserver-0" do |c|
      c.vm.hostname = "nfsserver-0"
      c.vm.network "private_network", ip: "192.168.199.50"

      c.vm.provision :shell, :path => "scripts/vagrant-setup-nfsserver.bash"    
      c.vm.provider "virtualbox" do |vb|
          vb.memory = 256
          vb.cpus = 1
      end        
    end

    # Ingress 
    # 192.168.199.30 will be the ingress IP, acc
    config.vm.define "traefik-0" do |c|
        c.vm.hostname = "traefik-0"
        c.vm.network "private_network", ip: "192.168.199.30"
        c.vm.provision :shell, :path => "scripts/vagrant-setup-routes.bash"
    end
  end
  