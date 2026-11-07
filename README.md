# dotfiles

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

**Zsh の共通設定**: `~/.zshrc` から `~/.config/zsh/init.zsh` を読み込み、
`~/.zshrc.local` → `plugins.zsh` → `completion.zsh` → `integrations.zsh` →
`aliases.zsh` → Starship の順に初期化する。
設定本体は `dot_config/zsh/`（配置先: `~/.config/zsh/`）で管理する。
共通のエイリアスは `aliases.zsh` に追加する。
`integrations.zsh` は PATH 上の fzf（0.48.0 以上）を検出して、キーバインドと
曖昧検索による補完を自動で有効にする。Brewfile から fzf をインストールした後、
新しい Zsh セッションで利用できる。

### Zsh migration

各環境で最初の `chezmoi apply`（`--force` を含む）を実行すると、
ファイル適用前に `.zshrc` の移行処理が動く。インストーラーの再実行でも同じ処理を使う。
`--dry-run` は移行処理を実行しない。初回移行では `--exclude=scripts` を指定しない。

- `.zshrc` が未作成・空なら、共通設定を読み込む最小のファイルを作成する。
- 既知の分割済み旧設定（`.zshrc.local` を最初／最後に読む2種類）は自動移行し、
  末尾に追記された内容を保持する。
- それ以外の独自設定・古い構成は変更せず、適用を中断する。
- 変更前に `.zshrc` と `.zshrc.local` を各環境の
  `~/.zshrc-migration-backup.YYYYMMDDTHHMMSSZ/`（UTC）に保存する。
  同じ秒に作成済みの場合は `.1`、`.2` の連番を付ける。
  `.zshrc.local` 自体は変更しない。移行後の再適用で読み込み行は重複しない。
- `.zshrc` がシンボリックリンクや通常ファイル以外の場合は、変更せず中断する。

独自設定で停止した場合は、表示されたバックアップを確認し、`.zshrc` を手動で整理する。
マシン固有の設定は残し、共通の plugins・completion・integrations・aliases・Starship と
`.zshrc.local` の初期化部分を、次の1行に置き換える。重複した初期化は取り除く。

```zsh
[[ -f ~/.config/zsh/init.zsh ]] && source ~/.config/zsh/init.zsh
```

共通設定の検出処理が使う PATH はこの行より前に置く。
インストーラーが末尾に PATH を追加した場合も、必要に応じて順序を調整する。
`zsh -n ~/.zshrc` で構文を確認し、`chezmoi apply` を再実行する。
作業中のシェルを残したまま別のシェルで動作を確認する。
復旧する場合は、バックアップ内のファイルを元の場所へコピーして戻す。

### Neovim

Neovim の設定は `dot_config/nvim/` で管理し、chezmoi が `~/.config/nvim/` にコピーする。

| ファイル | 内容 |
| --- | --- |
| `init.lua` | 基本設定と Leader キー |
| `lua/config/lazy.lua` | lazy.nvim の導入と初期化 |
| `lua/plugins/init.lua` | プラグイン設定とキーマッピング |
| `lazy-lock.json` | プラグインの固定バージョン |

Neovim 0.11.3 以上と Git をインストールして `chezmoi apply` を実行し、`nvim` を起動する。
初回起動では lazy.nvim とプラグインを自動で取得するため、ネットワーク接続が必要。
保存済みのプラグインバージョンを復元するには `:Lazy restore` を実行する。
Lua・JSON（JSONC を含む）・YAML・Python（Pyright）言語サーバーは macOS / Linux 共通で Mason が自動インストールし、有効化する。
JSON・YAML・Python 言語サーバーには Node.js と npm が必要（macOS は Brewfile に含む）。
Ubuntu / WSL は `install-ubuntu.sh` が nvm と最新 LTS の Node.js（npm 同梱）を
インストールし、nvm のデフォルトに設定する。再実行時も最新 LTS に更新する。
nvm は `${NVM_DIR:-$HOME/.nvm}` に配置し、
インストーラーによる `.zshrc` 等への追記は無効にする。
Linux では共通の `~/.config/zsh/init.zsh` が nvm を読み込むため、
シェルを再起動すると Neovim からも Node.js / npm を利用できる。
バージョンの追加・切り替えには `nvm install` / `nvm use` を使う。
初回インストールの状況は `:Mason` で確認できる。
入力中は blink.cmp が LSP・ファイルパス・スニペット・バッファ内の単語の補完候補を表示する。
候補のドキュメントも自動表示する。
`:` のコマンド入力は noice.nvim により画面上部中央のフローティングウィンドウに表示する。`/`・`?` の検索入力は画面下部に表示する。
コマンド名や引数の補完候補を自動表示し、`Ctrl-n` / `Ctrl-p` で選択、`Ctrl-y` で確定する。
確定後、`Enter` でコマンドを実行する。
全文検索の `Space fg` には ripgrep (`rg`) が必要。
アイコン表示には Nerd Font 3.3 以上をインストールし、端末で使用するフォントとして選択する。

JSON・JSONC・YAML はスペース2個のインデントを使用する。
言語サーバーの起動後、ノーマルモードの `Space cf` でファイル全体を整形できる。
保存時の自動整形は行わない。
JSON・JSONC は構文、YAML はインデントに基づいて折りたたみ、最初はすべて展開して表示する。
1行の JSON は整形して複数行にしてから折りたたむ。

| キー | 操作 |
| --- | --- |
| `Space cf` | LSP でファイル全体を整形 |
| `Ctrl-n` / `Ctrl-p` | 挿入モードで次 / 前の補完候補を選択 |
| `Ctrl-y` | 補完候補を確定 |
| `Ctrl-Space` | 補完候補を表示 / ドキュメントを表示 |
| `Ctrl-e` | 補完候補を閉じる |
| `za` | カーソル位置の折りたたみを開閉 |
| `zc` / `zo` | カーソル位置を閉じる / 開く |
| `zM` / `zR` | すべて閉じる / 開く |

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

### Lua lint

Neovim の Lua 設定は [Selene](https://github.com/Kampfkarren/selene) で検査する。
CI は pull request と main への push 時に実行する。
`selene.toml` と `neovim.yml` は lint 専用で、chezmoi の適用対象には含めない。
Neovim の `vim` グローバルを許可するが、API 名や引数の型までは検証しない。

Rust / Cargo がある環境では、CI と同じバージョンを導入して実行できる:

```zsh
cargo install selene --version 0.31.0 --locked
selene dot_config/nvim
```

### Brewfile の更新

1. 以下のコマンドを実行する:

   ```zsh
   brew bundle dump --global --no-vscode --force
   ```

   VS Code 拡張を Homebrew で管理している場合は `--no-vscode` を外す。
