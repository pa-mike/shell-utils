#!/bin/bash

source "$(dirname "$0")/../../shells/bash/utils.sh"
action_echo "Installing k3s"

curl -sfL https://get.k3s.io | sh -

