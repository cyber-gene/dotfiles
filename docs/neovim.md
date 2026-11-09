# Neovim

[README に戻る](../README.md)

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

## Lua lint

Neovim の Lua 設定は [Selene](https://github.com/Kampfkarren/selene) で検査する。
CI は pull request と main への push 時に実行する。
`selene.toml` と `neovim.yml` は lint 専用で、chezmoi の適用対象には含めない。
Neovim の `vim` グローバルを許可するが、API 名や引数の型までは検証しない。

Rust / Cargo がある環境では、CI と同じバージョンを導入して実行できる:

```zsh
cargo install selene --version 0.31.0 --locked
selene dot_config/nvim
```
