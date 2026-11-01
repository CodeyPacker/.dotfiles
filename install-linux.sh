#!/bin/sh

set -eu

if ! command -v pacman >/dev/null 2>&1; then
  echo "install-linux.sh supports Arch-based distributions such as CachyOS." >&2
  exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DOTFILES_ROOT=${DOTFILES_ROOT:-$SCRIPT_DIR}
DOTFILES_PROFILE=${DOTFILES_PROFILE:-linux}
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

echo "Setting up Linux profile: $DOTFILES_PROFILE"

# wl-clipboard backs Neovim's system clipboard on Wayland. ttf-droid provides
# Droid Sans Mono, the WezTerm font on Linux.
sudo pacman -Syu --needed --noconfirm \
  base-devel \
  curl \
  git \
  glow \
  go \
  lazygit \
  neovim \
  nodejs \
  npm \
  ripgrep \
  starship \
  tmux \
  ttf-droid \
  ttf-hack-nerd \
  unzip \
  wezterm \
  wl-clipboard \
  zsh \
  zsh-autosuggestions

if [ ! -d "$OH_MY_ZSH" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

if ! command -v herdr >/dev/null 2>&1; then
  curl -fsSL https://herdr.dev/install.sh | sh
fi

mkdir -p "$HOME/.local/share/fonts" "$HOME/.config/dotfiles"
cp -n "$DOTFILES_ROOT/fonts/"*.ttf "$HOME/.local/share/fonts/"
fc-cache -f "$HOME/.local/share/fonts"
printf '%s\n' "$DOTFILES_PROFILE" > "$HOME/.config/dotfiles/profile"

link_path "$DOTFILES_ROOT/zsh/.zshrc" "$HOME/.zshrc"
link_path "$DOTFILES_ROOT/nvim" "$HOME/.config/nvim"
link_path "$DOTFILES_ROOT/tmux/tmux.conf" "$HOME/.tmux.conf"
link_path "$DOTFILES_ROOT/wezterm" "$HOME/.config/wezterm"
link_path "$DOTFILES_ROOT/herdr" "$HOME/.config/herdr"
link_path "$DOTFILES_ROOT/starship/starship.toml" "$HOME/.config/starship.toml"
link_path "$DOTFILES_ROOT/ai/prompts" "$HOME/.config/ai-prompts"
link_path "$DOTFILES_ROOT/ai/prompts/sr_opus_5_system_prompt.md" "$HOME/.claude/CLAUDE.md"
link_path "$DOTFILES_ROOT/ai/prompts/sr_opus_5_system_prompt.md" "$HOME/.codex/AGENTS.md"
link_path "$DOTFILES_ROOT/ai/skills/tour" "$HOME/.claude/skills/tour"

# The aliases, prompt, and tmux config all assume Zsh, so make it the login
# shell instead of CachyOS's default fish.
zsh_path=$(command -v zsh)
current_shell=$(getent passwd "$(id -un)" | cut -d: -f7)
if [ "$current_shell" != "$zsh_path" ]; then
  echo "Changing login shell to $zsh_path..."
  chsh -s "$zsh_path"
fi

echo "Done. Log out and back in so the new login shell takes effect, then open WezTerm."
