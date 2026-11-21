#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if [ "$(uname -s)" = "Linux" ]; then
  if grep -qi microsoft /proc/version 2>/dev/null; then
    exec "$SCRIPT_DIR/install-wsl.sh" "$@"
  fi
  exec "$SCRIPT_DIR/install-linux.sh" "$@"
fi

if [ "$(uname -s)" != "Darwin" ]; then
  echo "install.sh supports macOS, WSL, and Arch-based Linux." >&2
  exit 1
fi

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
# Herdr desktop app mods live in their own repos under ~/personal, same as on Windows.
# A mod is linked only when its repo is cloned. Keep this list in step with install.ps1.
link_mod() {
  mod_source=$1
  mod_name=$2

  if [ -d "$mod_source" ]; then
    link_path "$mod_source" "$HOME/.config/herdr-app/mods/$mod_name"
  else
    echo "Skipping Herdr mod $mod_name, not found: $mod_source"
  fi
}

if [ -d "$HOME/.config/herdr-app" ]; then
  for mod in branch bruno brunr git-good jump keybinds portal run spotify tickets tourist vaultr zen; do
    link_mod "$HOME/personal/herdr-mods/$mod/mods/$mod" "$mod"
  done
  # The islands mods are copied once, not linked: the app keeps a settings file in one of them,
  # and a link would write that file into the herdr-mods repo. Windows has copies too.
  for mod in islands-agents islands-pane islands-spaces islands-tabs islands-workspace-chrome islands-workspace-status; do
    mod_source="$HOME/personal/herdr-mods/islands/mods/$mod"
    mod_target="$HOME/.config/herdr-app/mods/$mod"
    if [ -e "$mod_target" ]; then
      echo "Already installed: $mod_target"
    elif [ -d "$mod_source" ]; then
      mkdir -p "$HOME/.config/herdr-app/mods"
      cp -R "$mod_source" "$mod_target"
      echo "Copied $mod_source to $mod_target"
    else
      echo "Skipping Herdr mod $mod, not found: $mod_source"
    fi
  done
  link_mod "$HOME/personal/sharp/mod" sharp
  link_mod "$HOME/personal/tutor/mod" tutor
  # Folders only. Herdr rewrites its settings files in place, which would replace a file link.
  for dir in themes layouts backgrounds; do
    link_path "$DOTFILES_ROOT/herdr-app/$dir" "$HOME/.config/herdr-app/$dir"
  done
else
  echo "Herdr app config folder not found, skipping its links: $HOME/.config/herdr-app"
fi
# The settings files (keys, hints, settings, islands opacity) are copied by sync-config.sh.
# The post-merge hook reruns it after a git pull.
# Run "herdr-app/sync-config.sh push" to save changes made in the app.
"$DOTFILES_ROOT/herdr-app/sync-config.sh" pull
git -C "$DOTFILES_ROOT" config core.hooksPath .githooks
link_path "$DOTFILES_ROOT/starship/starship.toml" "$HOME/.config/starship.toml"
link_path "$DOTFILES_ROOT/ai/prompts" "$HOME/.config/ai-prompts"
link_path "$DOTFILES_ROOT/ai/prompts/sr_opus_5_system_prompt.md" "$HOME/.claude/CLAUDE.md"
link_path "$DOTFILES_ROOT/ai/prompts/sr_opus_5_system_prompt.md" "$HOME/.codex/AGENTS.md"
link_path "$DOTFILES_ROOT/ai/skills/tour" "$HOME/.claude/skills/tour"
link_path "$DOTFILES_ROOT/ai/skills/tech-spec" "$HOME/.claude/skills/tech-spec"

echo "Done. Open a new terminal to load the updated configuration."
