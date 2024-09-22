#!/bin/sh

# Enable immediate exit on error
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Paths
DOTFILES=$HOME/.dotfiles
OH_MY_ZSH=$HOME/.oh-my-zsh
FONTS=$DOTFILES/fonts
POWER_LEVEL_10K=$HOME/.oh-my-zsh/custom/themes/powerlevel10k

# Log errors and exit
log_error() {
  local message="$1"
  echo -e "${RED}ERROR: $message${RESET}" >&2
}

# Trap any command with a non-zero exit status
trap 'log_error "Command failed with exit code $?"' ERR

echo "${GREEN}Setting Up Your Mac...${RESET}"

# Install Oh-My-Zsh if not already installed
if [ ! -d "$OH_MY_ZSH" ]; then
  echo "${GREEN}Installing Oh-My-Zsh...${RESET}"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else 
  echo "${CYAN}Oh-My-Zsh Already Installed${RESET}" 
fi

# Install PowerLevel10K if not already installed
if [ ! -d "$POWER_LEVEL_10K" ]; then
  echo "${GREEN}Installing PowerLevel10K${RESET}"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$POWER_LEVEL_10K"
else
  echo "${CYAN}PowerLevel10K Already installed${RESET}"
fi

# Setup Powerlevel10k
echo "${GREEN}Init PowerLevel10K Settings${RESET}"
rm -rf $HOME/.p10k.zsh
ln -s $DOTFILES/zsh/.p10k.zsh $HOME/.p10k.zsh

# Install Homebrew if not already installed.
if test ! $(which brew); then
  echo "${GREEN}Installing Homebrew...${RESET}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
else 
  echo "${CYAN}Homebrew Already Installed${RESET}"
fi

# Check if the font is already installed
echo "${GREEN}Installing Fonts...${RESET}"
rsync -r --ignore-existing $FONTS/* $HOME/Library/Fonts

# Setup zsh
echo "${GREEN}Init .zshrc config...${RESET}"
rm -rf $HOME/.zshrc
ln -s $DOTFILES/zsh/.zshrc $HOME/.zshrc

# Setup Homebrew
echo "${GREEN}Update brew and install packages...${RESET}"
brew update
brew tap homebrew/bundle
brew bundle --file Brewfile

# Setup nvim
echo "${GREEN}Init Neovim Config...${RESET}"
if [ ! -d "$HOME/.config" ]; then
  mkdir "$HOME/.config"
else 
  rm -rf $HOME/.config/nvim
fi
ln -s $DOTFILES/nvim $HOME/.config/nvim

# Setup tmux
echo "${GREEN}Init .tmux.conf...${RESET}"
rm -rf $HOME/.tmux.conf
ln -s $DOTFILES/tmux/tmux.conf $HOME/.tmux.conf

# Setup Starship
echo "${GREEN}Init .config/starship.toml...${RESET}"
rm -rf $HOME/.config/starship.toml
ln -s $DOTFILES/starship/starship.toml $HOME/.config/starship.toml

echo "${GREEN}Done!${RESET}"

