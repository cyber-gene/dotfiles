# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS dotfiles repository that manages shell, editor, terminal, and system configurations via symlinks into `$HOME`.

## Setup & Installation

**Fresh install (bootstraps everything):**
```zsh
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/cyber-gene/dotfiles/main/install.zsh)"
```

This script installs Homebrew, git, zplug, creates symlinks, and runs `brew bundle --global`.

**Create symlinks only:**
```zsh
./link.zsh       # skip existing targets
./link.zsh -f    # force overwrite (backs up non-symlink files)
```

**Update Brewfile after installing/removing packages:**
```zsh
brew bundle dump --global --no-vscode --force
```

**Install all Homebrew packages from Brewfile:**
```zsh
brew bundle --global
```

## Repository Structure & Symlinking Logic

`link.zsh` symlinks files into `$HOME` using two rules:
- All dotfiles at the repo root (e.g. `.zshrc`, `.vimrc`) → `~/<filename>`
- Everything inside `.config/` → `~/.config/<name>` (not the `.config` dir itself)

The `.git` and `.config` directories are excluded from the root-level symlinking loop.

## Key Configurations

| File | Purpose |
|------|---------|
| `.zshrc` | Zsh with zplug, Powerlevel10k theme, fzf |
| `.p10k.zsh` | Powerlevel10k prompt config (generated, edit via `p10k configure`) |
| `.vimrc` | Vim with vim-plug plugins |
| `.tmux.conf` | tmux config; prefix remapped to `C-t` |
| `.gitconfig` | Git config; commits signed via SSH key (1Password ssh-agent) |
| `.Brewfile` | Homebrew bundle; installed to `~/.Brewfile` via symlink |
| `.config/alacritty/alacritty.toml` | Alacritty terminal config |
| `.config/wezterm/wezterm.lua` | WezTerm terminal config |

## Submodules

`.config/alacritty/theme` is a git submodule pointing to `alacritty/alacritty-theme`. After cloning, initialize with:
```zsh
git submodule update --init --recursive
```

## Vim Plugins (vim-plug)

Plugins are declared in `.vimrc` and stored in `.vim/plugged/`. Manage with:
- `:PlugInstall` — install plugins
- `:PlugUpdate` — update plugins
- `:PlugClean` — remove unused plugins

## Git Signing

All commits are signed with an SSH key via 1Password (`op-ssh-sign`). The signing key and GPG SSH program are configured in `.gitconfig`. 1Password must be running and unlocked for commits to succeed.
