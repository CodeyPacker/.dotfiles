export PATH=/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set Theme
eval "$(starship init zsh)"

# Set zsh-completions
fpath=(/usr/local/share/zsh-completions $fpath)

# ZSH Plugins
plugins=(
  git
  nvm
  brew
  z
)

source $ZSH/oh-my-zsh.sh

# -------------------
# User Configurations
# -------------------

# Aliases
source $HOME/.dotfiles/zsh/aliases.zsh

# zsh-autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

