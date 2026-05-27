# dotfiles

## Install

1. Run ```zsh -c "$(curl -fsSL https://raw.githubusercontent.com/cyber-gene/dotfiles/main/install.zsh)"```

## Maintenance

### chezmoi

Dotfiles are managed by [chezmoi](https://www.chezmoi.io/). The source directory is `~/dotfiles` and files are copied (not symlinked) to `$HOME`.

| Command | Description |
|---------|-------------|
| `chezmoi diff` | Preview what `apply` would change |
| `chezmoi apply` | Apply source to `$HOME` |
| `chezmoi edit --apply ~/.zshrc` | Edit a managed file and apply immediately |
| `chezmoi add ~/.foo` | Import a new file into the source |
| `chezmoi status` | Show which targets are out of sync |
| `chezmoi re-add` | Re-import all modified targets into source |

**After a git pull:**
```zsh
git pull && chezmoi apply
```

**Machine-local config** (not tracked by git): add to `~/.zshrc.local`.
Useful for PATH entries that installers append automatically.

### Update Brewfile

1. Execute ```brew bundle dump``` command.
    ```zsh
    brew bundle dump --global --no-vscode --force
    ```
    If you manage VS Code extensions with Homebrew, make sure to exclude the ```--no-vscode``` option.