# dotfiles

macOS / Ubuntu / WSL の設定を chezmoi で管理する dotfiles。

## 必要なもの・導入されるもの

- インストールにはネットワーク接続が必要。Ubuntu / WSL では sudo を使用する。
- macOS: Homebrew・Git・chezmoi・zplug と、[Brewfile](dot_Brewfile) にある CLI・アプリ・フォントなどを導入する。
- Ubuntu / WSL: [apt パッケージ一覧](scripts/ubuntu-packages.txt) と、chezmoi・Starship・zplug・nvm・Node.js / npm を導入する。
- Neovim: 0.11.3 以上、Git、言語サーバー用の Node.js / npm が必要。
  初回起動で lazy.nvim・プラグイン・言語サーバーを取得する。
- Neovim の全文検索には ripgrep (`rg`)、アイコン表示には端末で Nerd Font 3.3 以上の指定が必要。
  macOS は Brewfile に含む。Ubuntu / WSL では別途用意する。

## インストール

### macOS

1. 以下のコマンドを実行する:

   ```zsh
   zsh -c "$(curl -fsSL https://raw.githubusercontent.com/cyber-gene/dotfiles/main/install.zsh)"
   ```

### Ubuntu / WSL

Ubuntu 26.04 LTS 以降を使用する（WSL の Ubuntu 環境も同様）。
Homebrew を使わず、`apt` で基本パッケージ、nvm で Node.js / npm をインストールする。

1. 以下のコマンドを実行する:

   ```bash
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/cyber-gene/dotfiles/main/install-ubuntu.sh)"
   ```

既存環境の更新にも、各 OS のインストールコマンドを再実行できる。
既存の `~/dotfiles` を `git pull` で最新化し、chezmoi の管理対象ファイルを
リポジトリの内容で確認プロンプトなしに上書きする（ローカル変更も上書きされる）。

## メンテナンス

### chezmoi

dotfiles は [chezmoi](https://www.chezmoi.io/) で管理している。ソースディレクトリは `~/dotfiles` で、ファイルは `$HOME` にコピーされる（シンボリックリンクではない）。

| コマンド | 説明 |
| --- | --- |
| `chezmoi diff` | `apply` で変更される内容をプレビューする |
| `chezmoi apply` | ソースを `$HOME` に適用する |
| `chezmoi edit --apply ~/.config/zsh/init.zsh` | 管理ファイルを編集してすぐに適用する |
| `chezmoi add ~/.foo` | 新しいファイルをソースに取り込む |
| `chezmoi status` | 同期が取れていないファイルを確認する |
| `chezmoi re-add` | 変更済みのファイルをすべてソースに再取り込みする |

**git pull 後の適用:**

```zsh
git pull && chezmoi apply --force
```

**マシン固有の設定**: `~/.zshrc` は chezmoi 管理外で、インストーラーの追記も保持する。
既存の `~/.zshrc.local` も引き続き読み込む。どちらも `chezmoi add` しない。

Zsh の読み込み順序や初回適用時の `.zshrc` 移行手順は [Zsh の詳細](docs/zsh.md) を参照する。

### Neovim の設定・プラグインの更新

設定を編集して適用する:

```zsh
chezmoi edit --apply ~/.config/nvim/lua/plugins/init.lua
```

`:Lazy update` でプラグインを更新した後は、ロックファイルを取り込む:

```zsh
chezmoi add ~/.config/nvim/lazy-lock.json
```

固定バージョンへの復元は `:Lazy restore`、言語サーバーの導入状況の確認は `:Mason` を使う。
設定構成・キーマッピング・Lua lint は [Neovim の詳細](docs/neovim.md) を参照する。

### Brewfile の更新

macOS では `dot_Brewfile` にパッケージを追加して `chezmoi apply` を実行すると、
不足分が自動でインストールされる。インストールスクリプトの再実行は不要。
初回と Brewfile の内容が変わった時だけチェックし、インストール済みの
パッケージに対する一括更新・削除は行わない（追加パッケージの依存関係で更新される場合はある）。
失敗した場合は、次の `chezmoi apply` で再試行する。

1. 以下のコマンドを実行する:

   ```zsh
   brew bundle dump --global --no-vscode --force
   ```

   VS Code 拡張を Homebrew で管理している場合は `--no-vscode` を外す。

### Ubuntu / WSL の apt パッケージの更新

Ubuntu（WSL の Ubuntu を含む）では `scripts/ubuntu-packages.txt` に
パッケージ名を1行ずつ追加し、`chezmoi apply` を実行する。
初回と一覧・インストール処理の変更時だけ確認し、不足分がある場合に限り
`apt-get update` とインストールを行う（通常ユーザーでは sudo を使用する）。
既存パッケージの一括更新・削除は行わず、失敗した場合は次回の apply で再試行する。
初期インストーラーも、この一覧の適用を chezmoi に任せる。
Node.js / nvm・starship・zplug の導入は引き続き初期インストーラーが行う。
