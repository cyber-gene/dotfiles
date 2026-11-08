# shellcheck shell=bash
# Shared aliases
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first --git'
alias lt='eza --tree --level=2 --icons'

if command -v nvim &>/dev/null; then
  alias vi='nvim'
  alias vim='nvim'
fi
