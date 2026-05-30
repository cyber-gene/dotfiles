# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

macOS のシェル・エディタ・ターミナル・システム設定を [chezmoi](https://www.chezmoi.io/) で管理する dotfiles リポジトリ。chezmoi がソースファイルを `$HOME` にコピーして適用する（シンボリックリンクではない）。

## セットアップ・インストール

**新規インストール（全自動）:**

```zsh
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/cyber-gene/dotfiles/main/install.zsh)"
```

Homebrew・git・chezmoi・zplug のインストール、chezmoi による dotfiles の適用、`brew bundle --global` の実行を行う。

**chezmoi の適用のみ実行（既存環境の更新）:**

```zsh
chezmoi apply
```

**Homebrew パッケージ管理:**

```zsh
brew bundle dump --global --no-vscode --force   # Brewfile を現在の環境に合わせて更新
brew bundle --global                             # Brewfile からパッケージを一括インストール
```

## chezmoi の仕組み

`~/dotfiles` がソースディレクトリ。`chezmoi apply` 実行時にファイルを `$HOME` にコピーする。

**ファイル命名規則:**

- `dot_` プレフィックス → `$HOME` では `.` に変換（例: `dot_zshrc` → `~/.zshrc`）
- `dot_config/` 内のファイル → `~/.config/` 以下にコピー

**除外ファイル（`.chezmoiignore`）:**  
`install.zsh`・`README.md`・`CLAUDE.md`・`.claude/`・`.kiri/` などはリポジトリ管理用のためコピーしない。

**chezmoi 設定ファイル（Git 管理外）:**  
`~/.config/chezmoi/chezmoi.toml` に `sourceDir = "~/dotfiles"` を設定する。

## 主要設定ファイル

| ソースファイル | 適用先 | 用途 |
| --- | --- | --- |
| `dot_zshrc` | `~/.zshrc` | zplug・Powerlevel10k・fzf を使った Zsh 設定 |
| `dot_p10k.zsh` | `~/.p10k.zsh` | Powerlevel10k プロンプト設定（`p10k configure` で再生成） |
| `dot_vimrc` | `~/.vimrc` | vim-plug プラグイン付き Vim 設定 |
| `dot_tmux.conf` | `~/.tmux.conf` | tmux 設定（プレフィックスは `C-t` に変更） |
| `dot_gitconfig` | `~/.gitconfig` | Git 設定（1Password SSH エージェント経由でコミット署名） |
| `dot_Brewfile` | `~/.Brewfile` | Homebrew バンドル |
| `dot_config/alacritty/alacritty.toml` | `~/.config/alacritty/alacritty.toml` | Alacritty ターミナル設定 |

## alacritty テーマ

`.chezmoiexternal.toml` で `alacritty/alacritty-theme` を外部 git リポジトリとして管理。
`chezmoi apply` 時に `~/.config/alacritty/theme/` へ自動クローン・更新される（168時間ごとに更新）。git サブモジュールは使用していない。

## ローカル専用設定

インストーラーが `~/.zshrc` に PATH 等を追記した場合は `~/.zshrc.local` に移動する。このファイルは Git 管理外で、`~/.zshrc` の末尾で自動的に source される。

```zsh
# インストーラーが ~/.zshrc に書き込んだ行を移動する手順
# 1. 追記された内容を先に ~/.zshrc.local へ移動する
#    （この時点では ~/.zshrc に追記内容が残っている）
# 2. chezmoi apply で ~/.zshrc をソースの状態に戻す
chezmoi apply   # 追記内容は ~/.zshrc.local に移動済みなので消えても問題ない
```

## Vim プラグイン（vim-plug）

プラグインは `dot_vimrc` で宣言し、`~/.vim/plugged/` に保存される（Git 管理外）。

- `:PlugInstall` — インストール
- `:PlugUpdate` — 更新
- `:PlugClean` — 未使用プラグインの削除

## Git コミット署名

すべてのコミットは 1Password（`op-ssh-sign`）経由の SSH キーで署名される。コミット時は 1Password が起動・ロック解除されている必要がある。
