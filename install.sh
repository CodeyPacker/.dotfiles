#!/bin/sh

set -eu

if [ "$(uname -s)" != "Darwin" ]; then
  echo "install.sh is for macOS. On WSL, run ./install-wsl.sh." >&2
  exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DOTFILES_ROOT=${DOTFILES_ROOT:-$SCRIPT_DIR}
DOTFILES_PROFILE=${DOTFILES_PROFILE:-personal-mac}
BACKUP_ROOT="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
OH_MY_ZSH="$HOME/.oh-my-zsh"

link_path() {
  source_path=$1
  target_path=$2

  mkdir -p "$(dirname -- "$target_path")"

  if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
    echo "Already linked: $target_path"
    return
  fi

  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    relative_path=${target_path#"$HOME"/}
    backup_path="$BACKUP_ROOT/$relative_path"
    mkdir -p "$(dirname -- "$backup_path")"
    mv "$target_path" "$backup_path"
    echo "Backed up $target_path to $backup_path"
  fi

  ln -s "$source_path" "$target_path"
  echo "Linked $target_path -> $source_path"
}

echo "Setting up macOS profile: $DOTFILES_PROFILE"

if [ ! -d "$OH_MY_ZSH" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

brew update
brew bundle --file "$DOTFILES_ROOT/Brewfile"

mkdir -p "$HOME/Library/Fonts" "$HOME/.config/dotfiles"
rsync -r --ignore-existing "$DOTFILES_ROOT/fonts/" "$HOME/Library/Fonts/"
printf '%s\n' "$DOTFILES_PROFILE" > "$HOME/.config/dotfiles/profile"

link_path "$DOTFILES_ROOT/zsh/.zshrc" "$HOME/.zshrc"
link_path "$DOTFILES_ROOT/nvim" "$HOME/.config/nvim"
link_path "$DOTFILES_ROOT/tmux/tmux.conf" "$HOME/.tmux.conf"
link_path "$DOTFILES_ROOT/wezterm" "$HOME/.config/wezterm"
link_path "$DOTFILES_ROOT/herdr" "$HOME/.config/herdr"
link_path "$DOTFILES_ROOT/starship/starship.toml" "$HOME/.config/starship.toml"

echo "Done. Open a new terminal to load the updated configuration."
