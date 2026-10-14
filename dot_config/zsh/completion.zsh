# shellcheck shell=bash
# brew zsh-completions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit
  compinit
fi

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
