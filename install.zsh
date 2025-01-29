#!/bin/zsh

# Install Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

else
  echo "Homebrew is already installed."
fi

# Install git
if ! command -v git &>/dev/null; then
  echo "Installing git..."
  brew install git
else
  echo "git is already installed."
fi

# Clone repository
REPO_URL="https://github.com/cyber-gene/dotfiles.git"
CLONE_DIR="$HOME/dotfiles"

if [ ! -d "$CLONE_DIR" ]; then
  echo "Cloning repository..."
  git clone "$REPO_URL" "$CLONE_DIR"
else
  echo "Repository already exists at $CLONE_DIR."
fi

# Install zplug
if [[ -z "$(typeset -f zplug)" && ! -d "$HOME/.zplug" ]]; then
  echo "Installing zplug..."
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
else
  echo "zplug is already installed."
fi

# Create symlinks
./link.zsh -f

source ~/.zshrc

# Verify installations
echo "Verifying installations..."
command -v brew && echo "Homebrew installation verified."
[[ -n "$(typeset -f zplug)" ]] && echo "zplug installation verified."

# Update and upgrade Homebrew
brew update
brew upgrade
# Install Homebrew packages
brew bundle --global