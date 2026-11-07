# shellcheck shell=bash disable=SC1090
# Machine-local environment (installer-appended PATH entries, etc.)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Ubuntu / WSL: npm を使う Mason の言語サーバーにも Node.js を提供する。
if [[ "$OSTYPE" == linux* ]]; then
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  # shellcheck source=/dev/null
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
fi

# Shared configuration (load order is intentional)
source ~/.config/zsh/plugins.zsh
source ~/.config/zsh/completion.zsh
source ~/.config/zsh/integrations.zsh
source ~/.config/zsh/aliases.zsh

# Starship prompt (must be last)
eval "$(starship init zsh)"
