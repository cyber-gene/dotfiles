#!/bin/zsh

# Install Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Update and upgrade Homebrew
  brew update
  brew upgrade
  # Install Homebrew packages
  brew bundle --global
else
  echo "Homebrew is already installed."
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
