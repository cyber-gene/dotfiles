# shellcheck shell=bash disable=SC1090
# Shared configuration (load order is intentional)
source ~/.config/zsh/plugins.zsh
source ~/.config/zsh/completion.zsh
source ~/.config/zsh/integrations.zsh
source ~/.config/zsh/aliases.zsh

# Machine-local additions (installer-appended PATH entries, etc.)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Starship prompt (must be last)
eval "$(starship init zsh)"
