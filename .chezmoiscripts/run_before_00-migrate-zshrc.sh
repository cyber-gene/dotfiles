#!/bin/bash
set -euo pipefail
exec bash "${CHEZMOI_SOURCE_DIR:?chezmoi source directory is required}/scripts/migrate-zshrc.sh"
