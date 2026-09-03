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
alias ll='ls -al'
alias tf='tofu'

source <(kubectl completion bash)
# Alias for kubectl and enable completion on alias
alias k='kubectl'
complete -F __start_kubectl k
