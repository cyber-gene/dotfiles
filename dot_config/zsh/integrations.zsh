# shellcheck shell=bash disable=SC1090
# 1Password Shell Plugins
[[ -f ~/.config/op/plugins.sh ]] && source ~/.config/op/plugins.sh

# fzf key bindings and fuzzy completion (fzf 0.48.0+)
if command -v fzf &>/dev/null; then
  source <(fzf --zsh)
fi
