script_dir=$(cd "$(dirname "$0")" && pwd)

# Parse options
force=false
while getopts "f" OPT; do
    case $OPT in
        f) force=true ;;
    esac
done

# Function to create symlink safely with backup
create_symlink() {
    local source="$1"
    local target="$2"

    # Handle existing files/directories
    if [[ -e "$target" || -L "$target" ]]; then
        if $force; then
            # Create backup with timestamp
            backup_target="${target}.backup.$(date +%Y%m%d_%H%M%S)"
            mv "$target" "$backup_target"
            echo "Backed up $target to $backup_target"
        else
            echo "$target already exists. Skipped."
            return
        fi
    fi

    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$target")"
    ln -s "$source" "$target"
    echo "Create symlink: $target -> $source"
}

# Handle regular dotfiles
for file in $script_dir/.*; do
    baseName="$(basename "$file")" 

    # Exclude ignore files and directories
    if [[ $baseName == "." 
        || $baseName == ".." 
        || $baseName == ".git" 
        || $baseName == ".config" ]]; then
        continue
    fi

    # Create symlinks for regular dotfiles
    if [[ -f "$file" || -d "$file" ]]; then
        target="$HOME/$baseName"
        create_symlink "$file" "$target"
    fi
done

# Handle .config directory contents
config_dir="$script_dir/.config"
if [[ -d "$config_dir" ]]; then
    for config_item in "$config_dir"/*; do
        if [[ -f "$config_item" || -d "$config_item" ]]; then
            config_basename="$(basename "$config_item")"
            target="$HOME/.config/$config_basename"

            create_symlink "$config_item" "$target"
        fi
    done
fi
