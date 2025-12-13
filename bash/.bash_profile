# .bash_profile
if [[ -f ~/.bashrc ]]; then
  source ~/.bashrc
fi

# Activate devbox
eval "$(devbox global shellenv)"

## Env
export VISUAL=nvim
export EDITOR=nvim

## Alias
alias vim='nvim'
alias ll='ls -al'
alias gs='git status'

source <(kubectl completion bash)
# Alias for kubectl and enable completion on alias
alias k='kubectl'
echo 'complete -F __start_kubectl k' >>~/.bashrc

# Set terminal style to vi instead of emacs
set -o vi
