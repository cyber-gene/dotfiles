#!/bin/zsh

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install zplug
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

script_dir=$(cd "$(dirname "$0")" && pwd)

for file in $script_dir/.*; do

    baseName="$(basename "$file")" 
    # . や .. を除外
    if [[ $baseName == "." 
        || $baseName == ".." 
        || $baseName == ".git" ]]; then
        continue
    fi

    # Create symlinks
    if [[ -f "$file" || -d "$file" ]]; then
        target="$HOME/$baseName"
        if [[ -e "$target" || -L "$target" ]]; then
            echo "$target is exist. Skiped."
        else
            ln -s "$file" "$target"
            echo "Create symlink: $target -> $file"
        fi
    fi
    echo $baseName
done

# Install brew packages
brew bundle --global
