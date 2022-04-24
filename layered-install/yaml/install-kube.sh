#! /bin/bash

sudo apt-get update

# DOCKER INSTALL - https://docs.docker.com/engine/install/ubuntu/
# Older versions of Docker were called docker, docker.io, or docker-engine. If these are installed, uninstall them:

# Deprecated remove docker, opted to have this step done earlier
# sudo apt-get remove docker docker-engine docker.io containerd runc  


sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

if [[ $(grep 'Ubuntu' /etc/os-release) =~ "Ubuntu" ]]
then
	echo 'Ubuntu'
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --batch --yes -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo \
	  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
	  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	sudo apt-get update
	sudo apt-get install docker-ce docker-ce-cli containerd.io -y
	export KUBE_EDITOR=nano

elif [[ $(grep 'darwin' /etc/os-release) =~ "darwin" ]]
then
	# https://docs.docker.com/desktop/mac/install/
	echo 'MacOS'
	brew cask install docker -y
fi



# KUBERNETES INSTALL - https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
sudo apt-get install apt-transport-https ca-certificates curl -y
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
# Add the Kubernetes apt repository:
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
# Update apt package index with the new repository and install kubectl:

sudo apt-get install kubectl -y

