#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
missing=()
while IFS= read -r package || [[ -n "$package" ]]; do
  [[ -z "$package" || "$package" == \#* ]] && continue
  if [[ ! "$package" =~ ^[a-z0-9][a-z0-9+.-]*(:[a-z0-9-]+)?$ ]]; then
    echo "Invalid apt package name: $package" >&2
    exit 1
  fi
  case "$(dpkg-query -W -f='${Status}' "$package" 2>/dev/null || true)" in
    "install ok installed"|"hold ok installed") ;;
    *) missing+=("$package") ;;
  esac
done < "$SCRIPT_DIR/ubuntu-packages.txt"

if (( ${#missing[@]} == 0 )); then
  echo "All required apt packages are installed."
  exit 0
fi

privilege=()
if (( EUID != 0 )); then
  privilege=(sudo)
fi
"${privilege[@]}" apt-get update -q
"${privilege[@]}" apt-get install -y --no-upgrade "${missing[@]}"
