# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

macOS のシェル・エディタ・ターミナル・システム設定を `$HOME` へのシンボリックリンクで管理する dotfiles リポジトリ。

## セットアップ・インストール

**新規インストール（全自動）:**
```zsh
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/cyber-gene/dotfiles/main/install.zsh)"
```
Homebrew・git・zplug のインストール、シンボリックリンクの作成、`brew bundle --global` の実行を行う。

**シンボリックリンクのみ作成:**
```zsh
./link.zsh       # 既存のターゲットはスキップ
./link.zsh -f    # 強制上書き（非シンボリックリンクはバックアップ）
```

**Homebrew パッケージ管理:**
```zsh
brew bundle dump --global --no-vscode --force   # Brewfile を現在の環境に合わせて更新
brew bundle --global                             # Brewfile からパッケージを一括インストール
```

## シンボリックリンクの仕組み

`link.zsh` は以下の2ルールで `$HOME` へシンボリックリンクを作成する:
- リポジトリルートのドットファイル（`.zshrc` など） → `~/<ファイル名>`
- `.config/` 内のすべて → `~/.config/<名前>`（`.config` ディレクトリ自体はリンクしない）

`.git` と `.config` ディレクトリはルートレベルのループから除外される。

## 主要設定ファイル

| ファイル | 用途 |
|----------|------|
| `.zshrc` | zplug・Powerlevel10k・fzf を使った Zsh 設定 |
| `.p10k.zsh` | Powerlevel10k プロンプト設定（`p10k configure` で再生成） |
| `.vimrc` | vim-plug プラグイン付き Vim 設定 |
| `.tmux.conf` | tmux 設定（プレフィックスは `C-t` に変更） |
| `.gitconfig` | Git 設定（1Password SSH エージェント経由でコミット署名） |
| `.Brewfile` | Homebrew バンドル（`~/.Brewfile` にシンボリックリンク） |
| `.config/alacritty/alacritty.toml` | Alacritty ターミナル設定 |

## サブモジュール

`.config/alacritty/theme` は `alacritty/alacritty-theme` を指す git サブモジュール。クローン後に初期化:
```zsh
git submodule update --init --recursive
```

## Vim プラグイン（vim-plug）

プラグインは `.vimrc` で宣言し、`.vim/plugged/` に保存される。
- `:PlugInstall` — インストール
- `:PlugUpdate` — 更新
- `:PlugClean` — 未使用プラグインの削除

## Git コミット署名

すべてのコミットは 1Password（`op-ssh-sign`）経由の SSH キーで署名される。コミット時は 1Password が起動・ロック解除されている必要がある。
