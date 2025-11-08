#!/usr/bin/env bash

# ============================================================================
# Remote Dotfiles Bootstrap Script
# ============================================================================
# Quick setup for lean terminal environment on remote Linux machines
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
DOTFILES_REPO="https://github.com/fgaens/dotfiles.git"
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
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$ID
    OS_VERSION=$VERSION_ID
  elif command_exists lsb_release; then
    OS=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
  else
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
  fi

  print_step "Detected OS: $OS"
}

# ----------------------------------------------------------------------------
# Install Dependencies
# ----------------------------------------------------------------------------

install_dependencies() {
  print_step "Installing dependencies..."

  local packages="zsh tmux vim git curl"

  case "$OS" in
    ubuntu|debian)
      sudo apt-get update -qq
      sudo apt-get install -y $packages
      ;;
    fedora)
      sudo dnf install -y $packages
      ;;
    centos|rhel)
      if [[ "${OS_VERSION%%.*}" -ge 8 ]]; then
        sudo dnf install -y $packages
      else
        sudo yum install -y $packages
      fi
      ;;
    arch|manjaro)
      sudo pacman -Sy --noconfirm $packages
      ;;
    alpine)
      sudo apk add --no-cache $packages
      ;;
    *)
      print_warning "Unknown OS. Please manually install: $packages"
      read -p "Press enter when dependencies are installed..."
      ;;
  esac

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
# Symlink Configs
# ----------------------------------------------------------------------------

symlink_configs() {
  print_step "Symlinking configuration files..."

  local remote_dir="$DOTFILES_DIR/remote"

  # Backup existing configs
  for config in .zshrc .bashrc .tmux.conf .vimrc; do
    if [[ -f "$HOME/$config" && ! -L "$HOME/$config" ]]; then
      print_warning "Backing up existing $config to ${config}.backup"
      mv "$HOME/$config" "$HOME/${config}.backup"
    fi
  done

  # Create symlinks
  ln -sf "$remote_dir/zsh/.zshrc" "$HOME/.zshrc"
  ln -sf "$remote_dir/bash/.bashrc" "$HOME/.bashrc"
  ln -sf "$remote_dir/tmux/.tmux.conf" "$HOME/.tmux.conf"
  ln -sf "$remote_dir/vim/.vimrc" "$HOME/.vimrc"

  print_success "Configs symlinked"
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
  echo "║  Lean terminal setup for remote Linux    ║"
  echo "╚═══════════════════════════════════════════╝"
  echo -e "${NC}"

  # Check if running on Linux
  if [[ "$(uname -s)" != "Linux" ]]; then
    print_error "This script is designed for Linux systems."
    exit 1
  fi

  # Detect OS
  detect_os

  # Check for sudo if needed
  if ! command_exists sudo && [[ $EUID -ne 0 ]]; then
    print_error "This script requires sudo access or root privileges."
    exit 1
  fi

  # Run installation steps
  install_dependencies
  setup_dotfiles
  install_zsh_plugins
  symlink_configs
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
