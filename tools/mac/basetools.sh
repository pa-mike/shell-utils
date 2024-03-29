#!/bin/bash

source "$(dirname "$0")/../../shells/bash/utils.sh"

action_echo "
---------------------------
   Setting up installers
---------------------------
"

action_echo "Installing brew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" NONINTERACTIVE=1
echo '# Set PATH, MANPATH, etc., for Homebrew.' >> /Users/$USER/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/$USER/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

action_echo "Installing mas"
brew install mas 

action_echo "
---------------------------------
   Starting base tool installs
---------------------------------
"

action_echo "Installing chrome"
brew install --cask google-chrome
open "/applications/Google Chrome.app"

action_echo "Installing slack"
brew install --cask slack
open /applications/Slack.app

action_echo "Installing spotify"
brew install --cask spotify
open "/applications/Spotify.app"

action_echo "Installing MeetingBar"
brew install --cask meetingbar
open "/applications/MeetingBar.app"

action_echo "Installing Bettertouchtool"
brew install --cask bettertouchtool
open "/applications/BetterTouchTool.app"

action_echo "Installing shottr"
brew install --cask shottr
open "/applications/Shottr.app"

action_echo "Installing Messenger"
brew install --cask messenger
open -a messenger



action_echo "
--------------------------
   Setting up dev tools 
--------------------------
"


action_echo "Installing vscode"
brew install --cask visual-studio-code
open "/applications/Visual Studio Code.app"

action_echo "Installing iterm2"
brew install iterm2
open "/applications/iTerm.app"

action_echo "Setting up gitconfig"
git config --global user.email "michael.gibbons@provision.io"
git config --global user.name "Michael Gibbons"

action_echo "Installing python poetry"
curl -sSL https://install.python-poetry.org | python3 -

action_echo "Installing Zsh autosuggestions"
source "$(dirname "$0")/../../shells/zsh/src/zsh-autosuggestions.sh"

action_echo "Installing oh-my-posh"
source "$(dirname "$0")/../../shells/zsh/src/ohmyposh.sh"

action_echo "Installing azure-cli"
brew install azure-cli

action_echo "Installing docker"
brew install docker

action_echo "Installing docker-compose"
brew install docker-compose

action_echo "Installing kubectl"
brew install kubernetes-cli@1.22

action_echo "Installing azure storage explorer"
brew install --cask microsoft-azure-storage-explorer

action_echo "Installing java"
brew install java

action_echo "Installing npm"
brew install node

action_echo "Installing Spotica Menu"
mas install 570549457