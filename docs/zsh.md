# Zsh

[README に戻る](../README.md)

## 共通設定

 `~/.zshrc` から `~/.config/zsh/init.zsh` を読み込み、
`~/.zshrc.local` → `plugins.zsh` → `completion.zsh` → `integrations.zsh` →
`aliases.zsh` → Starship の順に初期化する。
設定本体は `dot_config/zsh/`（配置先: `~/.config/zsh/`）で管理する。
共通のエイリアスは `aliases.zsh` に追加する。
`integrations.zsh` は PATH 上の fzf（0.48.0 以上）を検出して、キーバインドと
曖昧検索による補完を自動で有効にする。Brewfile から fzf をインストールした後、
新しい Zsh セッションで利用できる。

## .zshrc の移行

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
