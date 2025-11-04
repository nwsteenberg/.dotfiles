# .bash_profile

## Env
export VISUAL=nvim
export EDITOR=nvim

## Alias
alias vim='nvim'
alias ll='ls -al'
alias gs='git status'

alias k='kubectl'

# Set terminal style to vi instead of emacs
set -o vi

# Activate devbox
eval "$(devbox global shellenv)"
