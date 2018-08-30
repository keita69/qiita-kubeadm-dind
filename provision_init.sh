#!/bin/bash

### proxy setting
#USER=user
#PW=password
#SV=hoge.com
#PORT=8080
#echo "proxy=http://${USER}:${PW}@${SV}:${PORT}" > ~/.curlrc

#sudo tee -a /etc/yum.conf << EOS
#proxy = http://${SV}:${PORT}
#proxy_username = ${USER}
#proxy_password = ${PW}
#EOS

# SET UP THE REPOSITORY
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
  
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# INSTALL DOCKER CE
#sudo yum list docker-ce --showduplicates | sort -r
#sudo yum install docker-ce
sudo yum install -y docker-ce-18.06.1.ce-3.el7
sudo systemctl start docker
# sudo docker run hello-world

# INSTALL KUBECTL
sudo tee /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

#sudo yum list kubectl --showduplicates | sort -r
#sudo yum install -y kubectl
sudo yum install -y kubectl-1.10.7-0

# INSTALL KUBEADM-DIND 
wget https://cdn.rawgit.com/Mirantis/kubeadm-dind-cluster/master/fixed/dind-cluster-v1.10.sh
chmod +x dind-cluster-v1.10.sh

