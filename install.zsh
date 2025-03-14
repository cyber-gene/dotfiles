#!/bin/zsh

# Function to check if a command exists
command_exists() {
  command -v "$1" &>/dev/null
}

# Install Homebrew
if ! command_exists brew; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ $? -ne 0 ]; then
    echo "Failed to install Homebrew."
    exit 1
  fi
else
  echo "Homebrew is already installed."
fi

# Install git
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

# Clone repository
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
  echo "Repository already exists at $CLONE_DIR."
fi

# Install zplug
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

# Create symlinks
LINK_SCRIPT="$CLONE_DIR/link.zsh"
"$LINK_SCRIPT" -f
if [ $? -ne 0 ]; then
  echo "Failed to create symlinks."
  exit 1
fi

source ~/.zshrc

# Verify installations
echo "Verifying installations..."
command_exists brew && echo "Homebrew installation verified."
[[ -n "$(typeset -f zplug)" ]] && echo "zplug installation verified."

# Update and upgrade Homebrew
brew update
brew upgrade

# Install Homebrew packages
brew bundle --global
