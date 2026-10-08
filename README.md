# dotfiles

## インストール

### macOS

1. 以下のコマンドを実行する:

   ```zsh
   zsh -c "$(curl -fsSL https://raw.githubusercontent.com/cyber-gene/dotfiles/main/install.zsh)"
   ```

### Ubuntu / WSL

Homebrew を使わず、`apt` で最小限の依存パッケージのみをインストールする。

1. 以下のコマンドを実行する:

   ```bash
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/cyber-gene/dotfiles/main/install-ubuntu.sh)"
   ```

## メンテナンス

### chezmoi

dotfiles は [chezmoi](https://www.chezmoi.io/) で管理している。ソースディレクトリは `~/dotfiles` で、ファイルは `$HOME` にコピーされる（シンボリックリンクではない）。

| コマンド | 説明 |
| --- | --- |
| `chezmoi diff` | `apply` で変更される内容をプレビューする |
| `chezmoi apply` | ソースを `$HOME` に適用する |
| `chezmoi edit --apply ~/.zshrc` | 管理ファイルを編集してすぐに適用する |
| `chezmoi add ~/.foo` | 新しいファイルをソースに取り込む |
| `chezmoi status` | 同期が取れていないファイルを確認する |
| `chezmoi re-add` | 変更済みのファイルをすべてソースに再取り込みする |

**git pull 後の適用:**

```zsh
git pull && chezmoi apply
```

**マシン固有の設定**（git 管理外）: `~/.zshrc.local` に追記する。
インストーラーが自動で追加した PATH エントリなどを置く場所として使う。

### Neovim

Neovim の設定は `dot_config/nvim/` で管理し、chezmoi が `~/.config/nvim/` にコピーする。

| ファイル | 内容 |
| --- | --- |
| `init.lua` | 基本設定と Leader キー |
| `lua/config/lazy.lua` | lazy.nvim の導入と初期化 |
| `lua/plugins/init.lua` | プラグイン設定とキーマッピング |
| `lazy-lock.json` | プラグインの固定バージョン |

Neovim と Git をインストールして `chezmoi apply` を実行し、`nvim` を起動する。
初回起動では lazy.nvim とプラグインを自動で取得するため、ネットワーク接続が必要。
保存済みのプラグインバージョンを復元するには `:Lazy restore` を実行する。
全文検索の `Space fg` には ripgrep (`rg`) が必要。

設定を編集して適用する:

```zsh
chezmoi edit --apply ~/.config/nvim/lua/plugins/init.lua
```

Neovim で `:Lazy update` などを実行してプラグインを更新した後は、
変更されたロックファイルを取り込む:

```zsh
chezmoi add ~/.config/nvim/lazy-lock.json
```

プラグイン本体・キャッシュは管理対象に含めない。

### Brewfile の更新

1. 以下のコマンドを実行する:

   ```zsh
   brew bundle dump --global --no-vscode --force
   ```

   VS Code 拡張を Homebrew で管理している場合は `--no-vscode` を外す。
