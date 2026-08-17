#!/bin/sh

set -eu

if ! grep -qi microsoft /proc/version 2>/dev/null; then
  echo "install-wsl.sh must be run inside WSL." >&2
  exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DOTFILES_ROOT=${DOTFILES_ROOT:-$SCRIPT_DIR}
DOTFILES_PROFILE=${DOTFILES_PROFILE:-personal-windows}
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

install_neovim() {
  case "$(uname -m)" in
    x86_64) asset_name="nvim-linux-x86_64" ;;
    aarch64|arm64) asset_name="nvim-linux-arm64" ;;
    *)
      echo "Unsupported Neovim architecture: $(uname -m)" >&2
      exit 1
      ;;
  esac

  temporary_root=$(mktemp -d)
  archive_path="$temporary_root/$asset_name.tar.gz"
  install_path="$HOME/.local/opt/nvim"

  curl -fsSL \
    "https://github.com/neovim/neovim/releases/latest/download/$asset_name.tar.gz" \
    -o "$archive_path"
  tar -xzf "$archive_path" -C "$temporary_root"

  if [ -e "$install_path" ]; then
    backup_path="$BACKUP_ROOT/nvim-install"
    mkdir -p "$(dirname -- "$backup_path")"
    mv "$install_path" "$backup_path"
  fi

  mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
  mv "$temporary_root/$asset_name" "$install_path"
  ln -sfn "$install_path/bin/nvim" "$HOME/.local/bin/nvim"
  rm -rf "$temporary_root"
}

echo "Setting up WSL profile: $DOTFILES_PROFILE"

sudo apt-get update
sudo apt-get install -y \
  build-essential \
  curl \
  git \
  golang-go \
  nodejs \
  npm \
  ripgrep \
  tmux \
  unzip \
  zsh \
  zsh-autosuggestions

install_neovim

if [ ! -d "$OH_MY_ZSH" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

if ! command -v starship >/dev/null 2>&1; then
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

if ! command -v herdr >/dev/null 2>&1; then
  curl -fsSL https://herdr.dev/install.sh | sh
fi

mkdir -p "$HOME/.config/dotfiles"
printf '%s\n' "$DOTFILES_PROFILE" > "$HOME/.config/dotfiles/profile"

link_path "$DOTFILES_ROOT/zsh/.zshrc" "$HOME/.zshrc"
link_path "$DOTFILES_ROOT/nvim" "$HOME/.config/nvim"
link_path "$DOTFILES_ROOT/tmux/tmux.conf" "$HOME/.tmux.conf"
link_path "$DOTFILES_ROOT/herdr" "$HOME/.config/herdr"
link_path "$DOTFILES_ROOT/starship/starship.toml" "$HOME/.config/starship.toml"
link_path "$DOTFILES_ROOT/ai/prompts" "$HOME/.config/ai-prompts"
link_path "$DOTFILES_ROOT/ai/prompts/sr_opus_5_system_prompt.md" "$HOME/.claude/CLAUDE.md"
link_path "$DOTFILES_ROOT/ai/prompts/sr_opus_5_system_prompt.md" "$HOME/.codex/AGENTS.md"

echo "Done. Run 'chsh -s $(command -v zsh)' if you want Zsh as your default WSL shell."
echo "Then open a new WezTerm window."
