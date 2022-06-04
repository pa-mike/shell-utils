#!/bin/bash

source "$(dirname "$0")/../../shells/bash/utils.sh"

action_echo "Installing zsh"
sudo apt-get update
sudo apt install zsh -y


source "$(dirname "$0")/../../shells/zsh/src/ohmyposh.sh"
source "$(dirname "$0")/../../shells/zsh/src/zsh-autosuggestions.sh"