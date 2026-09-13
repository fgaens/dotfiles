# Remote Dotfiles

Lean, portable terminal configuration for macOS and Ubuntu systems.

## Features

### Shell (Zsh)
- ✨ Vi-mode with history substring search (j/k in vi-mode)
- 🎨 Syntax highlighting (green/red command validation)
- 💡 Auto-suggestions from history
- 📝 Enhanced tab completions
- 🖥️ Smart prompt with:
  - Tmux session name (if in tmux)
  - Git branch + status indicator
  - Command duration (for slow commands)

### Tmux
- ⌨️ Vim-style keybindings (hjkl navigation)
- ➗ Intuitive splits (| and -)
- 🎯 Sensible defaults
- 🎨 Clean status bar
- No plugins required

### Vim
- 📊 Line numbers with relative numbering
- 🔍 Smart search (case-insensitive unless uppercase)
- ⚡ Essential keybindings
- 📝 Clean status line
- 🚫 No plugins, pure vim

### Bash Fallback
- Similar experience when zsh isn't available
- Vi-mode
- Git + duration in prompt
- Same aliases

## Quick Install

### One-Liner

**Note:** First, update the `DOTFILES_REPO` URL in `install.sh` with your GitHub username!

```bash
curl -fsSL https://raw.githubusercontent.com/fgaens/dotfiles/main/remote/install.sh | bash
```

### Manual Installation

```bash
# 1. Clone dotfiles
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles/remote

# 2. Update the repo URL in install.sh
vim install.sh  # Change YOUR_USERNAME to your GitHub username

# 3. Run installer
bash install.sh
```

The script will:
1. Detect your OS (macOS or Ubuntu)
2. Install dependencies (zsh, tmux, vim, git, stow)
3. Download zsh plugins
4. Stow configuration files into `$HOME`
5. Install OpenCode and Claude Code if they are not already on `PATH`
6. Optionally set zsh as default shell

## What Gets Installed

### System Packages
- `zsh` - Modern shell
- `tmux` - Terminal multiplexer
- `vim` - Text editor
- `git` - Version control
- `curl` - For downloading plugins
- `stow` - Links the remote packages into `$HOME`
- **macOS only**: `homebrew` (installed automatically if not present)

### Zsh Plugins (to `~/.zsh-plugins/`)
- `zsh-syntax-highlighting` - Command syntax validation
- `zsh-autosuggestions` - History-based suggestions
- `zsh-history-substring-search` - Better history search
- `zsh-completions` - Additional completions

### Config Files (stowed to `~/`)
- `.zshrc` - Zsh configuration
- `.bashrc` - Bash fallback configuration
- `.tmux.conf` - Tmux configuration
- `.vimrc` - Vim configuration

These are GNU Stow packages under `remote/{zsh,bash,tmux,vim}`. The installer runs `stow -d ~/dotfiles/remote -t ~ zsh bash tmux vim`. Do not `stow remote` from the repo root — that would also link `install.sh` and this README into `$HOME`.

### Coding agents (if missing)
- `opencode` — [OpenCode](https://opencode.ai) native installer → `~/.local/bin`
- `claude` — [Claude Code](https://code.claude.com/docs/en/install) native installer → `~/.local/bin`

Skipped when the binary is already on `PATH`. `~/.local/bin` and `~/.opencode/bin` are on the remote shell `PATH`.

## Directory Structure

```
~/dotfiles/remote/
├── install.sh           # Bootstrap script
├── README.md            # This file
├── zsh/
│   └── .zshrc          # Lean zsh config with custom prompt
├── bash/
│   └── .bashrc         # Similar bash config for fallback
├── tmux/
│   └── .tmux.conf      # Minimal tmux with vim bindings
└── vim/
    └── .vimrc          # Essential vim settings
```

## Usage

### Starting Fresh Session
```bash
# Start zsh (if not default)
zsh

# Start tmux
tmux

# Or start tmux with a named session
tmux new -s work
```

### Key Bindings

#### Zsh
- `Ctrl+[` or `Esc` - Enter vi command mode
- In vi-mode: `j` - Previous matching command (history search)
- In vi-mode: `k` - Next matching command (history search)
- Start typing + `j/k` - Search history by prefix

#### Tmux
- `Ctrl+b |` - Split vertically
- `Ctrl+b -` - Split horizontally
- `Ctrl+b h/j/k/l` - Navigate panes (vim-style)
- `Ctrl+b r` - Reload config
- `Ctrl+b [` - Enter copy mode (vi-style)

#### Vim
- `Space` - Leader key
- `Space w` - Save file
- `Space q` - Quit
- `Space /` - Clear search highlight
- `Ctrl+h/j/k/l` - Navigate splits

## Customization

### Local Overrides
Each config sources a local override file if it exists:
- `~/.zshrc.local` - Local zsh customizations
- `~/.bashrc.local` - Local bash customizations
- `~/.vimrc.local` - Local vim customizations

Create these files to add machine-specific settings without modifying tracked configs.

### Example `.zshrc.local`
```bash
# Machine-specific aliases
alias deploy='ssh deploy@production'

# Custom PATH
export PATH="$HOME/bin:$PATH"

# Company-specific tools
source /opt/company/env.sh
```

## Supported Systems

- macOS (via Homebrew)
- Ubuntu / Debian-based distributions

The installer auto-detects your OS and uses the appropriate package manager (brew or apt).

## Troubleshooting

### Zsh plugins not loading
```bash
# Check if plugins were downloaded
ls ~/.zsh-plugins/

# Manually re-download
cd ~/dotfiles/remote
bash install.sh
```

### Prompt not showing git info
```bash
# Ensure you're in a git repository
git status

# Check git is installed
which git
```

### Tmux colors look wrong
```bash
# Check TERM variable
echo $TERM

# Should be: screen-256color (in tmux)
# or: xterm-256color (outside tmux)
```

### Want to uninstall?
```bash
# Unstow remote packages
cd ~/dotfiles/remote
stow -D -t "$HOME" zsh bash tmux vim

# Restore backups
mv ~/.zshrc.backup ~/.zshrc
mv ~/.bashrc.backup ~/.bashrc
# etc...

# Remove plugins
rm -rf ~/.zsh-plugins
```

## Differences from Main Setup

This remote setup is intentionally minimal compared to the main dotfiles:
- ❌ No Zim framework (plugins downloaded directly)
- ❌ No Neovim/Kickstart (basic vim instead)
- ❌ No TPM (tmux plugin manager)
- ✅ GNU Stow (same as the main setup; packages live under `remote/`)
- ✅ Supports only macOS and Ubuntu (streamlined for simplicity)

This keeps the setup:
- ⚡ Fast to install
- 🪶 Lightweight to run
- 🔧 Easy to troubleshoot
- 📦 Minimal dependencies

## Philosophy

> "Perfect is the enemy of good."

This setup aims for **good enough** - a comfortable, productive terminal environment that:
- Installs in < 2 minutes
- Works on any modern Linux
- Feels familiar if you're used to vim/tmux
- Doesn't require constant maintenance

If you need the full development setup, use the main dotfiles on your primary machine.
