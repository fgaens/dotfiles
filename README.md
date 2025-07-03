# Dotfiles
Personal configuration files managed with GNU Stow.

## Setup on a New System

### Prerequisites
GNU Stow

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
