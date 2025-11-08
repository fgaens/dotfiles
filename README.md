# Dotfiles
Personal configuration files managed with GNU Stow.

## Two Setups Available

### 🏠 Main Setup (This Directory)
Full-featured development environment for primary machines (Mac/Linux workstations).
- Zsh with Zim framework
- Neovim with Kickstart
- Tmux with plugins
- Uses GNU Stow for management

### 🌐 Remote Setup ([`remote/`](remote/))
Lean, portable configuration for remote Linux servers. Quick to install, minimal dependencies.
- **[→ See Remote Setup Guide](remote/README.md)**
- One-liner installation
- No framework overhead
- Works on any modern Linux

---

## Main Setup - Installation

Use this for your primary development machine.

## Setup on a New System

### Prerequisites
```bash
sudo apt install make unzip gcc ripgrep fd-find xclipGNU Stow
```

### Installation

1. Clone this repository:
```bash
git clone https://github.com/fgaens/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. Apply configurations:
```bash
# Apply all configurations
stow */

# Or apply specific packages
stow zsh git nvim
```

## Usage

### Apply a Package
```bash
stow packagename
```

### Remove a Package
```bash
stow -D packagename
```

### Dry Run (see what would happen)
```bash
stow -n packagename
```

### Re-stow (useful after updates)
```bash
stow -R packagename
```

---

## Remote Setup

For quick setup on remote Linux servers, see the **[Remote Setup Guide](remote/README.md)**.

### Quick Install on Remote Server
```bash
curl -fsSL https://raw.githubusercontent.com/fgaens/dotfiles/main/remote/install.sh | bash
```

This gives you a lean but comfortable terminal experience with:
- Zsh with syntax highlighting, autosuggestions, and smart prompt
- Tmux with vim keybindings
- Vim with essential configuration
- Bash fallback for older systems
