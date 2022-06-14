#!/bin/bash

source "$(dirname "$0")/../../shells/bash/utils.sh"
action_echo "Installing k3s"

curl -sfL https://get.k3s.io | sh -

# Set permissions (REMOVE IN PROD)
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config && chown $USER ~/.kube/config && chmod 600 ~/.kube/config && export KUBECONFIG=~/.kube/config