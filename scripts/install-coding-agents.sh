#!/usr/bin/env bash
# Install OpenCode and Claude Code when they are not already on PATH.
# Official native installers; works on macOS and Ubuntu.

set -euo pipefail

export PATH="${HOME}/.local/bin:${HOME}/.opencode/bin:${HOME}/bin:${PATH}"
mkdir -p "${HOME}/.local/bin"

already_installed() {
  command -v "$1" >/dev/null 2>&1
}

install_opencode() {
  if already_installed opencode; then
    echo "OpenCode already installed ($(command -v opencode))"
    return 0
  fi
  echo "Installing OpenCode..."
  OPENCODE_INSTALL_DIR="${HOME}/.local/bin" curl -fsSL https://opencode.ai/install | bash
  if ! already_installed opencode; then
    echo "error: OpenCode installed but not on PATH" >&2
    return 1
  fi
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

install_opencode
install_claude
