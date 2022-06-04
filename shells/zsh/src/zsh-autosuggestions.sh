#!/bin/bash

source "$(dirname "$0")/../../bash/utils.sh"

action_echo "Installing zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
add_unique_line_to_file "source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ~/.zshrc 
add_unique_line_to_file "export ZSH_AUTOSUGGEST_STRATEGY=(history completion)" ~/.zshrc