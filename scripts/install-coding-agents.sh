#!/usr/bin/env bash
# Install Claude Code when it is not already on PATH.
# Official native installer; works on macOS and Ubuntu.

set -euo pipefail

export PATH="${HOME}/.local/bin:${HOME}/bin:${PATH}"
mkdir -p "${HOME}/.local/bin"

already_installed() {
  command -v "$1" >/dev/null 2>&1
}

install_claude() {
  if already_installed claude; then
    echo "Claude Code already installed ($(command -v claude))"
    return 0
  fi
  echo "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
  if ! already_installed claude; then
    echo "error: Claude Code installed but not on PATH" >&2
    return 1
  fi
}

install_claude
