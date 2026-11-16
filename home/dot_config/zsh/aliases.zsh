# VIM -> NVIM
if command -v nvim >/dev/null 2>&1; then
  alias vim="nvim"
fi

# Docker
alias dc="docker compose"
alias dcr="dc run --rm"
alias dcrp="dcr --service-ports --use-aliases"
alias dce="dc exec"

# Copy the current Git branch with the platform's native clipboard command.
gcopy() {
  local branch
  branch=$(git branch --show-current) || return
  if command -v pbcopy >/dev/null 2>&1; then
    printf '%s' "$branch" | pbcopy
  elif command -v clip.exe >/dev/null 2>&1; then
    printf '%s' "$branch" | clip.exe
  elif command -v wl-copy >/dev/null 2>&1; then
    printf '%s' "$branch" | wl-copy
  elif command -v xclip >/dev/null 2>&1; then
    printf '%s' "$branch" | xclip -selection clipboard
  else
    printf '%s\n' "$branch"
  fi
}

# Yarn aliases
alias yc="yarn clean"
alias yd="yarn develop"
alias yr="yarn refresh"
alias ycyd="yarn clean && yarn develop"
alias ycys="yarn clean && yarn serve"

# Tmux fallback
alias ta="tmux attach -t"
alias tnew="tmux new -s"
alias tls="tmux ls"
alias tkill="tmux kill-session -t"
alias tkillall="tmux kill-server"

alias ll="ls -lAh"
