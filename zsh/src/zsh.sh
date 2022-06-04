source ./utils.sh

sudo apt-get update
sudo apt install zsh -y

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

add_unique_line_to_file "source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ~/.zshrc 
add_unique_line_to_file "export ZSH_AUTOSUGGEST_STRATEGY=(history completion)" ~/.zshrc
add_unique_line_to_file "source <(kubectl completion zsh)" ~/.zshrc
add_unique_line_to_file "source <(helm completion zsh)" ~/.zshrc