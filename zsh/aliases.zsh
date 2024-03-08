# VIM -> NVIM
if hash nvim 2>/dev/null; then
  alias vim="nvim"
fi

# Docker
alias dc="docker compose"
alias dcr="dc run --rm"
alias dcrp="dcr --service-ports --use-aliases"
alias dce="dc exec"

# Git 
alias gcopy="git branch --show-current | tr -d '\n' | pbcopy"  # Copy current Git branch name to clipboard

# Yarn aliases
alias yc="yarn clean"
alias yd="yarn develop"
alias ycyd="yarn clean && yarn develop"
alias ycys="yarn clean && yarn serve" 

# Misc
alias ll="ls -lAh"
