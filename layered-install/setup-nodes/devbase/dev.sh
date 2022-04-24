#! /bin/bash
sudo apt-get update
sudo apt-get install curl -y
sudo apt-get install p7zip-full -y
sudo apt-get install git -y

#Homebrew package manager
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

sudo apt-get install openjdk-11-jdk -y
sudo apt-get install maven -y

echo "Installing kube"
sudo bash ../setup-nodes/devbase/tools/install-kube.sh -b

