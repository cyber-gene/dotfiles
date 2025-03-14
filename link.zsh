script_dir=$(cd "$(dirname "$0")" && pwd)

# Parse options
force=false
while getopts "f" OPT; do
    case $OPT in
        f) force=true ;;
    esac
done

for file in $script_dir/.*; do

    baseName="$(basename "$file")" 
    # Exclude ignore files and directories
    if [[ $baseName == "." 
        || $baseName == ".." 
        || $baseName == ".git" ]]; then
        continue
    fi

    # Create symlinks
    if [[ -f "$file" || -d "$file" ]]; then
        target="$HOME/$baseName"
        
        if $force; then
            rm -rf "$target"
            echo "Remove $target"
        fi

        if [[ -e "$target" || -L "$target" ]]; then
            echo "$target already exists. Skipped."
        else
            ln -s "$file" "$target"
            echo "Create symlink: $target -> $file"
        fi
    fi
done
