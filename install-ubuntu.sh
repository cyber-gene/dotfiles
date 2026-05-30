#!/usr/bin/env bash
# Ubuntu / WSL 向け dotfiles インストールスクリプト
# Homebrew はスキップし、zsh・vim の動作に必要な最小限のみインストールする

set -euo pipefail

REPO_URL="https://github.com/cyber-gene/dotfiles.git"
CLONE_DIR="$HOME/dotfiles"
CHEZMOI_CONFIG="$HOME/.config/chezmoi/chezmoi.toml"

command_exists() { command -v "$1" &>/dev/null; }

# ─── apt パッケージ（最小限） ────────────────────────────────────────────────

echo ">>> apt パッケージをインストール..."
sudo apt-get update -q
sudo apt-get install -y \
  build-essential \
  curl \
  git \
  tmux \
  unzip \
  vim \
  wget \
  zsh

# ─── chezmoi ─────────────────────────────────────────────────────────────────

if ! command_exists chezmoi; then
  echo ">>> chezmoi をインストール..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi

export PATH="$HOME/.local/bin:$PATH"

# ─── starship ────────────────────────────────────────────────────────────────

if ! command_exists starship; then
  echo ">>> starship をインストール..."
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
else
  echo ">>> starship はインストール済み: $(starship --version)"
fi

# ─── dotfiles リポジトリ ──────────────────────────────────────────────────────

if [ ! -d "$CLONE_DIR" ]; then
  echo ">>> dotfiles リポジトリをクローン..."
  git clone "$REPO_URL" "$CLONE_DIR"
else
  # pull の前に remote URL を検証し、別リポジトリには触れない
  if ! git -C "$CLONE_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
    echo "エラー: $CLONE_DIR は git リポジトリではありません。削除して再実行してください。"
    exit 1
  fi
  ACTUAL_REPO_URL="$(git -C "$CLONE_DIR" remote get-url origin 2>/dev/null)"
  if [ "$ACTUAL_REPO_URL" != "$REPO_URL" ]; then
    echo "エラー: $CLONE_DIR は想定外のリポジトリです（$REPO_URL ではありません）。"
    echo "削除して再実行してください。"
    exit 1
  fi
  echo ">>> dotfiles リポジトリを最新化..."
  git -C "$CLONE_DIR" pull
fi

# ─── zplug ───────────────────────────────────────────────────────────────────

if [[ ! -d "$HOME/.zplug" ]]; then
  echo ">>> zplug をインストール..."
  curl -sL --proto-redir -all,https \
    https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
else
  echo ">>> zplug はインストール済み"
fi

# ─── chezmoi 設定 ─────────────────────────────────────────────────────────────

if [[ ! -f "$CHEZMOI_CONFIG" ]]; then
  echo ">>> chezmoi 設定を作成..."
  mkdir -p "$(dirname "$CHEZMOI_CONFIG")"
  printf 'sourceDir = "%s"\n' "$CLONE_DIR" > "$CHEZMOI_CONFIG"
else
  EXISTING_SOURCE="$(grep '^sourceDir' "$CHEZMOI_CONFIG" | sed 's/sourceDir *= *"\(.*\)"/\1/' || true)"
  if [[ "$EXISTING_SOURCE" != "$CLONE_DIR" ]]; then
    echo ">>> chezmoi sourceDir を更新: ${EXISTING_SOURCE:-<未設定>} → $CLONE_DIR"
    sed -i "s|^sourceDir *=.*|sourceDir = \"$CLONE_DIR\"|" "$CHEZMOI_CONFIG"
  else
    echo ">>> chezmoi 設定は $CLONE_DIR を指しています。"
  fi
fi

# ─── dotfiles を適用 ──────────────────────────────────────────────────────────

echo ">>> dotfiles を適用..."
chezmoi apply --source "$CLONE_DIR"

# ─── gitconfig の Linux 向け調整 ──────────────────────────────────────────────
# chezmoi apply 後に macOS 固有の op-ssh-sign パスを Linux 版に書き換える

GITCONFIG="$HOME/.gitconfig"
if grep -q '/Applications/1Password.app' "$GITCONFIG" 2>/dev/null; then
  OP_SSH_SIGN="$(command -v op-ssh-sign 2>/dev/null || true)"
  if [[ -n "$OP_SSH_SIGN" ]]; then
    echo ">>> gitconfig の op-ssh-sign パスを Linux 向けに更新: $OP_SSH_SIGN"
    sed -i "s|/Applications/1Password.app/Contents/MacOS/op-ssh-sign|$OP_SSH_SIGN|" "$GITCONFIG"
  else
    echo ">>> 警告: op-ssh-sign が見つかりません。gitconfig の署名設定は未更新です。"
    echo "         1Password Desktop (Linux) をインストール後、~/.gitconfig の"
    echo "         gpg.ssh.program を手動で設定してください。"
  fi
fi

# ─── デフォルトシェルを zsh に設定 ───────────────────────────────────────────

ZSH_PATH="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
  echo ">>> デフォルトシェルを zsh ($ZSH_PATH) に変更..."
  if ! grep -qx "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
  fi
  chsh -s "$ZSH_PATH"
fi

# ─── ~/.zshrc.local のひな型を作成（未存在時のみ） ───────────────────────────

ZSHRC_LOCAL="$HOME/.zshrc.local"
if [[ ! -f "$ZSHRC_LOCAL" ]]; then
  cat > "$ZSHRC_LOCAL" <<'LOCALEOF'
# ~/.zshrc.local — このマシン固有の設定（Git 管理外）

# chezmoi / starship（~/.local/bin）
export PATH="$HOME/.local/bin:$PATH"

# WSL: Windows 側の 1Password SSH エージェントを使う場合はコメントを外す
# export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
LOCALEOF
  echo ">>> ~/.zshrc.local のひな型を作成しました。"
fi

# ─── 完了 ─────────────────────────────────────────────────────────────────────

cat <<'EOF'

===================================================
 インストール完了
===================================================

次のステップ:
  1. シェルを再起動して zsh に切り替える
       exec zsh
  2. zsh 初回起動時に zplug が未インストールプラグインを
     インストールするか確認を求めます（y で承認）
  3. vim プラグインをインストールする
       vim +PlugInstall +qall
  4. 1Password SSH エージェントの設定（コミット署名用）:
     op-ssh-sign は 1Password Desktop (Linux) に同梱されています。
     ・Linux 版 1Password Desktop をインストールする:
         https://1password.com/downloads/linux/
     ・インストール後、~/.gitconfig の gpg.ssh.program が
         自動設定されていない場合は手動で op-ssh-sign のパスを記入する
     ・WSL から Windows 版 1Password を使う場合:
         - 1Password の設定 → 開発者 → SSH Agent を有効化
         - ~/.zshrc.local の SSH_AUTH_SOCK 行のコメントを外す
  5. マシン固有の設定は ~/.zshrc.local に追記してください

EOF
