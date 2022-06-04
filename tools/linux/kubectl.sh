#!/bin/bash
source "$(dirname "$0")/../../shells/bash/utils.sh"
action_echo "Installing kubectl"

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubectl

action_echo "Adding kubectl completion to zsh"
add_unique_line_to_file "source <(kubectl completion zsh)" ~/.zshrc

action_echo "Adding kubectl completion to bash"
add_unique_line_to_file "source <(kubectl completion zsh)" ~/.bashrc