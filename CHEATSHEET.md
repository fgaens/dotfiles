# Cheatsheet

**Prefix** `Ctrl+/` (tmux and Herdr). Press prefix, release, then the key. Prefix twice sends a literal `Ctrl+/`.

Tabs = tmux windows. Spaces = tmux sessions.

## Shared (tmux / Herdr)

| Key | Action |
| --- | --- |
| `c` | New tab/window |
| `n` / `p` | Next / previous tab/window |
| `1`–`9` | Jump to tab/window |
| `(` / `)` | Previous / next space/session |
| `\|` / `-` | Split side / stacked |
| `h` `j` `k` `l` | Move pane |
| `x` / `z` | Close / zoom pane |
| `[` | Copy mode (`v` select, `y` copy) |
| `d` / `q` | tmux detach / Herdr detach |

## Tmux only

| Key | Action |
| --- | --- |
| `^` | Last window |
| `,` / `&` / `w` | Rename / kill / list windows |
| `s` / `$` | Session list / rename |
| `F` | tmux-fzf |
| `r` / `R` / `I` | Reload / sensible reload / TPM install |

## Herdr only

| Key | Action |
| --- | --- |
| `w` / `g` | Space picker / goto |
| `Shift+N` `W` `D` | New / rename / close space |
| `Shift+T` / `Shift+X` | Rename / close tab |
| `Tab` / `Shift+Tab` | Cycle panes |
| `r` | Resize mode |
| `m` / `Shift+M` | Arrange / move pane |
| `e` `b` `s` | Scrollback / sidebar / settings |
| `Shift+R` / `?` | Reload / all bindings |

## Zsh

Vi mode. `Esc` = command mode.

| Key | Action |
| --- | --- |
| `j` / `k` (command mode) | Substring history |
| Up / Down | Ordinary history |
| `Ctrl+R` | fzf history |
| `Ctrl+T` | fzf path |
| `Alt+C` | fzf `cd` (`Esc` `c` if Alt fails) |
| `Tab` | Fuzzy completion |
| `F4` in fzf | Toggle preview |
| `Ctrl+X` `Ctrl+E` | Edit line in Neovim |
| Right / End | Accept autosuggestion |

## Neovim

| Key | Action |
| --- | --- |
| `Ctrl+P` / `Space` `ff` | Files |
| `Space` `fg` `fb` `fo` | Grep / buffers / recent |
