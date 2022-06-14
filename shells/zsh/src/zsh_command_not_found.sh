#!/bin/bash

source "$(dirname "$0")/../../bash/utils.sh"

action_echo "Installing zsh_command_not_found"

sudo apt install command-not-found -y
add_unique_line_to_file "source /etc/zsh_command_not_found" ~/.zshrc 
