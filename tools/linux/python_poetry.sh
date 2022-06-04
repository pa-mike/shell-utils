#!/bin/bash
source "$(dirname "$0")/../../shells/bash/utils.sh"
action_echo "Installing python poetry"

sudo apt update
sudo apt install python3-poetry -y


