# Dotfiles
Personal configuration files managed with GNU Stow.

## Two Setups Available

### 🏠 Main Setup (This Directory)
Development environment for the primary macOS workstation. For Linux servers, use the separate remote setup below.
- Zsh with Zim framework
- Neovim with lazy.nvim + fzf-lua
- Tmux with TPM (sensible, tmux-fzf)
- Herdr with Arrange keybindings
- OpenCode (global config, commands, Jenkins MCP wrapper)
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
brew install git stow zsh tmux neovim fzf ripgrep fd
```
Requires fzf >= 0.48 and Neovim >= 0.9. Use a Nerd Font for file icons.
Optional: `brew install rbenv bat` for Ruby version management and shell file previews.
SDKMAN is initialized only if installed separately. Zim bootstrap requires `curl` (included with macOS).
Install Herdr separately; the Arrange keybindings also require its `herdr-arrange` plugin.
> Note: `*/` globs every directory, including `remote/` and `docs/` (which must NOT be stowed from this directory). Apply the explicit packages below. The remote installer stows `remote/{zsh,bash,tmux,vim}` into `$HOME` itself.

### Installation

1. Clone this repository:
```bash
git clone https://github.com/fgaens/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. Apply configurations:
```bash
# Apply all configurations (explicit packages — remote/ and docs/ are separate)
stow git zsh zim tmux nvim herdr opencode

# Or apply specific packages
stow zsh zim git nvim
```

The `zsh` package needs `zim`. On the first shell launch Zim downloads its framework
and installs the declared modules; after module-list edits, run `zimfw install`.
Neovim bootstraps lazy.nvim and missing plugins on first launch.

3. Install TPM if it is not already present:
```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```
Start tmux and press `Ctrl+/`, then `Shift+I` to install the declared plugins.
The local tmux config uses `tmux-256color`; SSH destinations need that terminfo
entry too (`infocmp tmux-256color` on the destination checks availability).

### Cross-Tool Behavior

See the [keyboard cheatsheet](CHEATSHEET.md) for zsh, tmux, and Herdr shortcuts.
See [configuration review and operating notes](TERMINAL.md) for the
keybinding layers, search rules, clipboard behavior, reloads, and remaining caveats.
Herdr's `~/.config/herdr/config.toml` is managed by the `herdr` Stow package.
Only the text configuration is tracked; plugins, sockets, logs, and session state remain local.
OpenCode's authored files under `~/.config/opencode/` are the `opencode` Stow package
(`opencode.jsonc`, `tui.jsonc`, slim/quota config, `preset-from-path.js`, `/handoff`,
`AGENTS.md`, and `bin/jenkins-mcp.sh`). npm deps, slim-bundled skills, Herdr
integration plugins, backups, and `.oh-my-opencode-slim/` stay local.

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
