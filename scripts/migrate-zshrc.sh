# shellcheck shell=bash
# Called by chezmoi before updating managed files. Also usable directly:
# bash scripts/migrate-zshrc.sh /path/to/home
set -euo pipefail

destination=${1:-${CHEZMOI_DEST_DIR:?chezmoi destination is required}}
zshrc="$destination/.zshrc"
bootstrap='[[ -f ~/.config/zsh/init.zsh ]] && source ~/.config/zsh/init.zsh'

# Never replace symlinks, directories, or other special files automatically.
if [[ -L "$zshrc" || ( -e "$zshrc" && ! -f "$zshrc" ) ]]; then
  echo "Cannot migrate $zshrc: not a regular file. See README.md (Zsh migration)." >&2
  exit 1
fi
if [[ -f "$zshrc" ]] && grep -Fqx "$bootstrap" "$zshrc"; then
  exit 0
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# Historical configurations live separately from the migration logic.
legacy_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/legacy-zshrc"

# Only remove a byte-for-byte known prefix. Installer additions after it survive.
matched_lines=0
if [[ -s "$zshrc" ]]; then
  for legacy in "$legacy_dir"/*.zsh; do
    lines=$(wc -l < "$legacy")
    head -n "$lines" "$zshrc" > "$work/prefix"
    if cmp -s "$legacy" "$work/prefix"; then
      matched_lines=$lines
      break
    fi
  done
fi

# Back up both files before any migration, including an unknown configuration.
backup_base="$destination/.zshrc-migration-backup.$(date -u +%Y%m%dT%H%M%SZ)"
backup=$backup_base
collision=0
until (umask 077; mkdir "$backup") 2>/dev/null; do
  if [[ ! -e "$backup" && ! -L "$backup" ]]; then
    echo "Cannot create backup directory: $backup" >&2
    exit 1
  fi
  collision=$((collision + 1))
  backup="$backup_base.$collision"
done
for name in .zshrc .zshrc.local; do
  if [[ -e "$destination/$name" || -L "$destination/$name" ]]; then
    cp -pP "$destination/$name" "$backup/$name"
  fi
done
echo "Zsh migration backup: $backup"

if [[ -s "$zshrc" && "$matched_lines" -eq 0 ]]; then
  echo "Unknown configuration: $zshrc was preserved; apply stopped." >&2
  echo "Review README.md (Zsh migration), replace shared initialization with:" >&2
  echo "$bootstrap" >&2
  exit 1
fi

# Stage beside the destination so the final rename is atomic.
staged=$(mktemp "$destination/.zshrc-migration.XXXXXXXX")
trap 'rm -rf "$work"; rm -f "$staged"' EXIT
if [[ -f "$zshrc" ]]; then
  cp -p "$zshrc" "$staged"
fi
printf '%s\n' "$bootstrap" > "$staged"
if [[ "$matched_lines" -gt 0 ]]; then
  tail -n "+$((matched_lines + 1))" "$zshrc" >> "$staged"
fi
mv "$staged" "$zshrc"
