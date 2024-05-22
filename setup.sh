#!/bin/bash

cd ~

echo "Setting up macOS..."

if test ! $(which brew); then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Updating Homebrew..."
brew update

echo "Installing and configuring Git..."
brew install git
git config --global user.name "Armaan Vakharia"
git config --global user.email "43391096+armaan-v924@users.noreply.github.com"

echo "Installing fzf..."
brew install fzf

echo "Installing Stow..."
brew install stow

mkdir -p ~/.dotfiles
git clone https://github.com/armaan-v924/dotfiles ~/.dotfiles
cd ~/.dotfiles
stow .

echo "Installing Development Tools..."
brew install fish
brew install node
brew install yarn
brew install --cask 1password
brew install --cask 1password-cli
brew install --cask visual-studio-code
brew install --cask docker
brew install --cask jetbrains-toolbox
brew install --cask postman
brew install --cask github
brew install --cask miniconda
brew install --cask microsoft-openjdk
brew install python
brew install --cask cyberduck
brew install sshpass

echo "Installing Web Tools..."
brew install --cask google-chrome
brew install --cask firefox
brew install --cask nordvpn
brew install --cask transmission

echo "Installing Communication Tools..."
brew install --cask zoom
brew install --cask slack

echo "Installing Media Tools..."
brew install --cask spotify
brew install --cask mediamate
brew install --cask vlc
brew install --cask obs

echo "Installing Productivity Tools..."
brew install --cask microsoft-office
brew install --cask adobe-creative-cloud
brew install --cask adobe-acrobat-pro
brew install --cask handbrake

echo "Installing Utilities..."
brew install --cask betterdisplay
brew install --cask rectangle
brew install --cask hiddenbar

echo "Installing Games..."
brew install --cask steam
brew install --cash epic-games
brew install --cask minecraft