# shellcheck shell=bash disable=SC1090
# zplug
source ~/.zplug/init.zsh
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "vladmyr/dotfiles-plugin", from:oh-my-zsh
zplug "junegunn/fzf"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    # shellcheck disable=SC2162
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
# Make sure to use double quotes
zplug load
