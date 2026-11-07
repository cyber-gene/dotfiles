# shellcheck shell=bash disable=SC1090
# Machine-local environment (installer-appended PATH entries, etc.)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Shared configuration (load order is intentional)
source ~/.config/zsh/plugins.zsh
source ~/.config/zsh/completion.zsh
source ~/.config/zsh/integrations.zsh
source ~/.config/zsh/aliases.zsh

# Starship prompt (must be last)
eval "$(starship init zsh)"
