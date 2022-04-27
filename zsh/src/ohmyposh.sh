source ./utils.sh

sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh
add_unique_line_to_file "$(oh-my-posh init zsh --config=${PWD%/*/*}/ohmyposh/ohmyposh-config.json)" ~/.zshrc