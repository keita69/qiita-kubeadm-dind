#!/bin/bash

# 'BEHIND_PROXY' is set to true if the environment is behind a proxy.
BEHIND_PROXY=false

if [ ${BEHIND_PROXY} ]; then
  # mod your proxy info
  USER=XXXXXXXX
  PW=XXXXXXXX
  SV=XXXXXXXX.com
  PORT=8080

  # curl
  echo "proxy=http://${USER}:${PW}@${SV}:${PORT}" > ~/.curlrc
  # yum
  sudo tee -a /etc/yum.conf << EOS
proxy = http://${SV}:${PORT}
proxy_username = ${USER}
proxy_password = ${PW}
EOS
  # wget
  sudo tee -a /etc/wgetrc << EOS
http_proxy= http://${USER}:${PW}@${SV}:${PORT}/
https_proxy= http://${USER}:${PW}@${SV}:${PORT}/
ftp_proxy = http://${USER}:${PW}@${SV}:${PORT}/
EOS

fi

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

#proxy
if [ ${BEHIND_PROXY} ]; then
  # docker
  sudo cp /usr/lib/systemd/system/docker.service /etc/systemd/system/
  sudo sed -i -e "/^ExecStart/a Environment=\"HTTP_PROXY=http://${USER}:${PW}@${SV}:${PORT}\"" /etc/systemd/system/docker.service
fi

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
sudo yum install -y epel-release
sudo yum install -y jq

# INSTALL KUBEADM-DIND 
sudo yum -y install wget
sudo wget https://cdn.rawgit.com/Mirantis/kubeadm-dind-cluster/master/fixed/dind-cluster-v1.10.sh
sudo chmod +x dind-cluster-v1.10.sh
sudo ./dind-cluster-v1.10.sh up

# add kubectl directory to PATH
export PATH="$HOME/.kubeadm-dind-cluster:$PATH"

echo "######################################"
echo "   FINISH TO INSTALL KUBEADM-DIND !!  "
echo "######################################"


