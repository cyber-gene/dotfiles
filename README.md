# dotfiles

## インストール

1. 以下のコマンドを実行する:

   ```zsh
   zsh -c "$(curl -fsSL https://raw.githubusercontent.com/cyber-gene/dotfiles/main/install.zsh)"
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

### Brewfile の更新

1. 以下のコマンドを実行する:

   ```zsh
   brew bundle dump --global --no-vscode --force
   ```

   VS Code 拡張を Homebrew で管理している場合は `--no-vscode` を外す。
