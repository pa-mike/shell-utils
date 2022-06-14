#!/bin/bash

source "$(dirname "$0")/../../shells/bash/utils.sh"

action_echo "Installing zsh"
sudo apt-get update
sudo apt install zsh -y

add_unique_line_to_file "SAVEHIST=1000" ~/.zshrc
add_unique_line_to_file "HISTFILE=~/.zsh_history" ~/.zshrc


source "$(dirname "$0")/../../shells/zsh/src/ohmyposh.sh"
source "$(dirname "$0")/../../shells/zsh/src/zsh-autosuggestions.sh"
source "$(dirname "$0")/../../shells/zsh/src/zsh_command_not_found.sh"