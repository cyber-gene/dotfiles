# dotfiles

## Install

1. Run ```zsh -c "$(curl -fsSL https://raw.githubusercontent.com/cyber-gene/dotfiles/main/install.zsh)"```

## Maintenance

### Update Brewfile

1. Execute ```brew bundle dump``` command.
    ```zsh
    brew bundle dump --global --no-vscode --force
    ```
    If you manage VS Code extensions with Homebrew, make sure to exclude the ```--no-vscode``` option.