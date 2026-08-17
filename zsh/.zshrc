export PATH="/usr/local/bin:$HOME/.local/bin:$HOME/go/bin:$PATH"
export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"
export VISUAL="nvim"

if [[ -z "${DOTFILES_PROFILE:-}" && -r "$HOME/.config/dotfiles/profile" ]]; then
  export DOTFILES_PROFILE="$(<"$HOME/.config/dotfiles/profile")"
fi

if [[ -z "${DOTFILES_ROOT:-}" ]]; then
  export DOTFILES_ROOT="${${(%):-%N}:A:h:h}"
fi

if command -v brew >/dev/null 2>&1; then
  brew_prefix="$(brew --prefix)"
  fpath=("$brew_prefix/share/zsh-completions" $fpath)

  autosuggestions="$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -r "$autosuggestions" ]] && source "$autosuggestions"

  postgresql_bin="$brew_prefix/opt/postgresql@17/bin"
  [[ -d "$postgresql_bin" ]] && export PATH="$postgresql_bin:$PATH"
elif [[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

plugins=(git nvm brew z)
[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

source "$DOTFILES_ROOT/zsh/aliases.zsh"

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

local_override="$HOME/.config/dotfiles/zsh.local.zsh"
[[ -r "$local_override" ]] && source "$local_override"

unset brew_prefix autosuggestions postgresql_bin local_override
