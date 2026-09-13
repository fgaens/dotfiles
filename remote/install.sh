#!/usr/bin/env bash

# ============================================================================
# Remote Dotfiles Bootstrap Script
# ============================================================================
# Quick setup for lean terminal environment on macOS and Ubuntu
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/remote/install.sh | bash
#
# Or locally:
#   cd ~/dotfiles/remote && bash install.sh
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_REPO="https://github.com/fgaens/dotfiles"
DOTFILES_DIR="$HOME/dotfiles"
PLUGIN_DIR="$HOME/.zsh-plugins"

# ----------------------------------------------------------------------------
# Helper Functions
# ----------------------------------------------------------------------------

print_step() {
  echo -e "${BLUE}==>${NC} $1"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}!${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# ----------------------------------------------------------------------------
# OS Detection
# ----------------------------------------------------------------------------

detect_os() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    OS="macos"
  elif [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" ]] || [[ "$ID_LIKE" == *"ubuntu"* ]] || [[ "$ID_LIKE" == *"debian"* ]]; then
      OS="ubuntu"
    else
      print_error "Unsupported OS: $ID. Only macOS and Ubuntu-based systems are supported."
      exit 1
    fi
  else
    print_error "Cannot detect OS. Only macOS and Ubuntu-based systems are supported."
    exit 1
  fi

  print_step "Detected OS: $OS"
}

# ----------------------------------------------------------------------------
# Install Dependencies
# ----------------------------------------------------------------------------

install_dependencies() {
  print_step "Installing dependencies..."

  if [[ "$OS" == "macos" ]]; then
    # Install Homebrew if not present
    if ! command_exists brew; then
      print_step "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Install packages via Homebrew
    brew install zsh tmux vim git curl stow 2>/dev/null || true
  else
    # Ubuntu/Debian
    sudo apt-get update -qq
    sudo apt-get install -y zsh tmux vim git curl stow
  fi

  print_success "Dependencies installed"
}

# ----------------------------------------------------------------------------
# Clone/Update Dotfiles
# ----------------------------------------------------------------------------

setup_dotfiles() {
  if [[ -d "$DOTFILES_DIR" ]]; then
    print_step "Dotfiles directory exists, pulling latest..."
    cd "$DOTFILES_DIR"
    git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || true
  else
    print_step "Cloning dotfiles repository..."
    if [[ -n "${DOTFILES_REPO}" && "${DOTFILES_REPO}" != *"YOUR_USERNAME"* ]]; then
      git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    else
      print_warning "No repository configured. Using local files."
      # Assume we're running from the dotfiles/remote directory
      DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    fi
  fi

  print_success "Dotfiles ready at $DOTFILES_DIR"
}

# ----------------------------------------------------------------------------
# Install Zsh Plugins
# ----------------------------------------------------------------------------

install_zsh_plugins() {
  print_step "Installing zsh plugins..."

  mkdir -p "$PLUGIN_DIR"
  cd "$PLUGIN_DIR"

  # Array of plugins to install
  declare -A plugins=(
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions.git"
    ["zsh-history-substring-search"]="https://github.com/zsh-users/zsh-history-substring-search.git"
    ["zsh-completions"]="https://github.com/zsh-users/zsh-completions.git"
  )

  for plugin in "${!plugins[@]}"; do
    if [[ -d "$plugin" ]]; then
      print_step "Updating $plugin..."
      cd "$plugin" && git pull -q && cd ..
    else
      print_step "Installing $plugin..."
      git clone -q --depth=1 "${plugins[$plugin]}" "$plugin"
    fi
  done

  print_success "Zsh plugins installed"
}

# ----------------------------------------------------------------------------
# Stow Configs
# ----------------------------------------------------------------------------
# Packages live under remote/{zsh,bash,tmux,vim}. Do not stow the remote/
# directory itself from the repo root — that would also link install.sh and
# README.md into $HOME.

stow_configs() {
  print_step "Stowing configuration files..."

  local remote_dir="$DOTFILES_DIR/remote"

  if ! command_exists stow; then
    print_error "stow is required but not installed"
    exit 1
  fi

  for config in .zshrc .bashrc .tmux.conf .vimrc; do
    local dest="$HOME/$config"
    if [[ -L "$dest" ]]; then
      rm "$dest"
    elif [[ -e "$dest" ]]; then
      print_warning "Backing up existing $config to ${config}.backup"
      mv "$dest" "$HOME/${config}.backup"
    fi
  done

  stow -d "$remote_dir" -t "$HOME" zsh bash tmux vim
  print_success "Configs stowed"
}

# ----------------------------------------------------------------------------
# Set Default Shell
# ----------------------------------------------------------------------------

set_default_shell() {
  if [[ "$SHELL" == *"zsh"* ]]; then
    print_success "Zsh is already your default shell"
    return
  fi

  print_step "Would you like to set zsh as your default shell?"
  read -p "Change default shell to zsh? (y/N): " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    local zsh_path=$(command -v zsh)

    # Add zsh to /etc/shells if not present
    if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
      echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    # Change default shell
    if command_exists chsh; then
      chsh -s "$zsh_path"
      print_success "Default shell changed to zsh (restart session to apply)"
    else
      print_warning "chsh not available. Manually run: chsh -s $zsh_path"
    fi
  else
    print_warning "Keeping current shell. Run 'zsh' manually to try it out."
  fi
}

# ----------------------------------------------------------------------------
# Main Installation
# ----------------------------------------------------------------------------

main() {
  echo -e "${BLUE}"
  echo "╔═══════════════════════════════════════════╗"
  echo "║  Remote Dotfiles Bootstrap               ║"
  echo "║  Lean terminal setup (macOS & Ubuntu)    ║"
  echo "╚═══════════════════════════════════════════╝"
  echo -e "${NC}"

  # Detect OS
  detect_os

  # Run installation steps
  install_dependencies
  setup_dotfiles
  install_zsh_plugins
  stow_configs
  set_default_shell

  echo
  echo -e "${GREEN}╔═══════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║  ✓ Installation Complete!                ║${NC}"
  echo -e "${GREEN}╚═══════════════════════════════════════════╝${NC}"
  echo
  echo "Next steps:"
  echo "  1. Start a new shell session or run: exec zsh"
  echo "  2. Try tmux: tmux"
  echo "  3. Edit a file: vim test.txt"
  echo
  echo "Configuration files backed up with .backup extension"
  echo
}

# Run main function
main "$@"
