#!/bin/bash
# check if a go version is set

clear
echo "#################"
echo $0 $1
echo "#################"

nodeIp=$1

ls /usr/local/share/ca-certificates/dockerepo.hvl.io.crt > /dev/null 2>&1
CERT_INSTALLED=$?

if [ $CERT_INSTALLED -eq 0 ]; then
    echo "Cert Already Installed"
else
    echo "Installing Cert"
    sudo cp /vagrant/vagrantscripts/dockerepo.hvl.io/dockerepo.hvl.io.crt /usr/local/share/ca-certificates
    sudo update-ca-certificates 
fi

docker ps > /dev/null 2>&1
DOCKER_INSTALLED=$?

if [ $DOCKER_INSTALLED -eq 0 ]; then
    echo "Docker Already Installed"
else
    echo ">>> Installing docker"
    sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
    
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    echo ">>> Adding vagrant user to docker group"
    sudo usermod -aG docker vagrant
    sudo systemctl start docker
    sudo systemctl enable docker
fi

kubectl > /dev/null 2>&1
kubectl_INSTALLED=$?

if [ $kubectl_INSTALLED -eq 0 ]; then
    echo "kubectl Already Installed"
else
    echo ">>> Installing kubectl"
    apt-get update && apt-get install -y apt-transport-https curl
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

    bash -c 'cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF'
    apt-get update
    apt-get install -y kubectl
    # apt-mark hold kubectl

    # echo "Europe/Istanbul" | sudo tee /etc/timezone
    # ln -fs /usr/share/zoneinfo/Europe/Istanbul /etc/localtime
    # dpkg-reconfigure --frontend noninteractive tzdata
    sudo timedatectl set-timezone Europe/Istanbul
    swapoff -a
    sed -i '/ swap / s/^/#/' /etc/fstab    

    echo ">>> INSTALLING kubens kubectx installation"
    git clone https://github.com/ahmetb/kubectx /opt/kubectx
    ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
    ln -s /opt/kubectx/kubens /usr/local/bin/kubens

    echo ">>> INSTALLING Helm !!!"
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    rm ./get_helm.sh
    
    echo ">>> Time to do vagrant reload !!!"
    # sudo shutdown now -r
fi