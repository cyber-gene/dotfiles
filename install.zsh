#!/bin/zsh

# Function to check if a command exists
command_exists() {
  command -v "$1" &>/dev/null
}

# Add Homebrew to PATH if brew binary is executable at a known location
setup_brew_env() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

# Add Homebrew to PATH first (before checking if it's installed)
# This handles the case where brew is installed but not yet in PATH
setup_brew_env

# Install Homebrew if still not available
if ! command_exists brew; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ $? -ne 0 ]; then
    echo "Failed to install Homebrew."
    exit 1
  fi
  # Add to PATH after installation
  setup_brew_env
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

# Verify it's the right repo
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

# Install chezmoi
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

# Configure chezmoi source directory
CHEZMOI_CONFIG="$HOME/.config/chezmoi/chezmoi.toml"
if [[ ! -f "$CHEZMOI_CONFIG" ]]; then
  echo "Configuring chezmoi source directory..."
  mkdir -p "$(dirname "$CHEZMOI_CONFIG")"
  printf 'sourceDir = "%s"\n' "$CLONE_DIR" > "$CHEZMOI_CONFIG"
else
  echo "chezmoi config already exists at $CHEZMOI_CONFIG."
fi

# Apply dotfiles via chezmoi (replaces link.zsh)
# Pass --source explicitly to ensure the cloned repo is always used,
# regardless of what sourceDir the existing config may point to.
echo "Applying dotfiles..."
chezmoi apply --source "$CLONE_DIR"
if [ $? -ne 0 ]; then
  echo "Failed to apply dotfiles."
  exit 1
fi

# Verify installations
echo "Verifying installations..."
command_exists brew && echo "Homebrew installation verified."
command_exists chezmoi && echo "chezmoi installation verified."

# Install Homebrew packages
brew bundle --global
