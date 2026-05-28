#!/bin/zsh

# コマンドが存在するか確認するユーティリティ関数
command_exists() {
  command -v "$1" &>/dev/null
}

# brew バイナリが既知の場所にあれば PATH に追加する
setup_brew_env() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

# brew がインストール済みでも PATH に含まれていない場合があるため、先に PATH を設定する
setup_brew_env

# それでも brew が見つからなければインストールする
if ! command_exists brew; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ $? -ne 0 ]; then
    echo "Failed to install Homebrew."
    exit 1
  fi
  # インストール後に PATH を再設定する
  setup_brew_env
else
  echo "Homebrew is already installed."
fi

# git をインストールする
if ! command_exists git; then
  echo "Installing git..."
  brew install git
  if [ $? -ne 0 ]; then
    echo "Failed to install git."
    exit 1
  fi
else
  echo "git is already installed."
fi

# リポジトリをクローンする
REPO_URL="https://github.com/cyber-gene/dotfiles.git"
CLONE_DIR="$HOME/dotfiles"

if [ ! -d "$CLONE_DIR" ]; then
  echo "Cloning repository..."
  git clone "$REPO_URL" "$CLONE_DIR"
  if [ $? -ne 0 ]; then
    echo "Failed to clone repository."
    exit 1
  fi
else
  # 既存の clone が旧レイアウトの場合も最新化してから apply する
  echo "Repository already exists at $CLONE_DIR. Pulling latest..."
  git -C "$CLONE_DIR" pull
  if [ $? -ne 0 ]; then
    echo "Failed to pull latest changes."
    exit 1
  fi
fi

# 正しいリポジトリかどうかを検証する
if ! git -C "$CLONE_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "$CLONE_DIR is not a git repository. Please remove it and re-run this script."
  exit 1
fi
ACTUAL_REPO_URL="$(git -C "$CLONE_DIR" remote get-url origin 2>/dev/null)"
if [ "$ACTUAL_REPO_URL" != "$REPO_URL" ]; then
  echo "$CLONE_DIR is not the expected repository ($REPO_URL)."
  echo "Please remove it and re-run this script."
  exit 1
fi

# chezmoi をインストールする
if ! command_exists chezmoi; then
  echo "Installing chezmoi..."
  brew install chezmoi
  if [ $? -ne 0 ]; then
    echo "Failed to install chezmoi."
    exit 1
  fi
else
  echo "chezmoi is already installed."
fi

# zplug をインストールする
if [[ -z "$(typeset -f zplug)" && ! -d "$HOME/.zplug" ]]; then
  echo "Installing zplug..."
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
  if [ $? -ne 0 ]; then
    echo "Failed to install zplug."
    exit 1
  fi
else
  echo "zplug is already installed."
fi

# chezmoi のソースディレクトリを設定する
CHEZMOI_CONFIG="$HOME/.config/chezmoi/chezmoi.toml"
if [[ ! -f "$CHEZMOI_CONFIG" ]]; then
  echo "Configuring chezmoi source directory..."
  mkdir -p "$(dirname "$CHEZMOI_CONFIG")"
  printf 'sourceDir = "%s"\n' "$CLONE_DIR" > "$CHEZMOI_CONFIG"
else
  EXISTING_SOURCE="$(grep '^sourceDir' "$CHEZMOI_CONFIG" | sed 's/sourceDir *= *"\(.*\)"/\1/')"
  if [[ "$EXISTING_SOURCE" != "$CLONE_DIR" ]]; then
    echo "Updating chezmoi sourceDir from '${EXISTING_SOURCE:-<not set>}' to '$CLONE_DIR'..."
    if grep -q '^sourceDir' "$CHEZMOI_CONFIG"; then
      # 既存の sourceDir 行を上書きする
      sed -i '' "s|^sourceDir *=.*|sourceDir = \"$CLONE_DIR\"|" "$CHEZMOI_CONFIG"
    else
      # sourceDir 行がない場合は追記する
      printf 'sourceDir = "%s"\n' "$CLONE_DIR" >> "$CHEZMOI_CONFIG"
    fi
  else
    echo "chezmoi config already points to $CLONE_DIR."
  fi
fi

# chezmoi で dotfiles を適用する（link.zsh の代替）
echo "Applying dotfiles..."
chezmoi apply --source "$CLONE_DIR"
if [ $? -ne 0 ]; then
  echo "Failed to apply dotfiles."
  exit 1
fi

# インストールを確認する
echo "Verifying installations..."
command_exists brew && echo "Homebrew installation verified."
command_exists chezmoi && echo "chezmoi installation verified."

# Homebrew パッケージを一括インストールする
brew bundle --global
