# Terminal Setup

Reviewed on 2026-09-07 against Zsh 5.9, tmux 3.5a, Herdr 0.8.2,
Neovim 0.12.5 and fzf 0.74.3. Herdr's unversioned website may describe a newer
configuration schema; validate changes with the installed `herdr config check`.

## Configuration Ownership

| Tool | Active entry point | Owner |
| --- | --- | --- |
| Zsh | `~/.zshrc` | Stow package `zsh` |
| Zim | `~/.zimrc` | Stow package `zim` |
| tmux | `~/.config/tmux/tmux.conf` | Stow package `tmux` |
| Neovim | `~/.config/nvim` | Stow package `nvim` |
| Herdr | `~/.config/herdr/config.toml` | Stow package `herdr` |

All current Stow links resolve correctly. The relative Neovim link is valid.
`remote/` is a separate configuration, not the active local tmux or editor setup.
The `herdr` package contains only `config.toml`. Do not add the rest of the live
Herdr directory: it contains sockets, logs, session state, and machine-specific
plugin installation paths. Install Herdr and the Arrange plugin separately.

## Shell Initialization

Homebrew precedes system tools; SDKMAN candidates and rbenv shims precede
Homebrew; `~/.local/bin` has highest priority. Login shells in macOS tmux and
Herdr run `path_helper`, so the shell explicitly restores tool precedence.
PATH and completion paths are deduplicated. Zim module paths are rebuilt for
each shell and the completed FPATH is not exported to children.

Zim owns `compinit`, input, prompt, fzf integration, syntax highlighting,
history substring search and autosuggestions. Do not add a second `compinit`,
`fzf --zsh`, or another prompt initializer to `.zshrc`.

The framework bootstrap has bounded download time and only promotes a download
after a syntax check. New module installation can still require network access.
An existing generated initialization file cannot certify that every module
succeeded: check startup diagnostics when changing the module list.

`EDITOR` and `VISUAL` both select Neovim. rbenv and SDKMAN are optional.
The existing `oc` alias runs `opencode --auto`, which auto-approves permissions
not explicitly denied. It was preserved, but should only be used for trusted work.
`k`/`j` in shell vi command mode search history substrings; arrow keys retain
ordinary history navigation. Ctrl+R invokes fzf history even in vi command mode,
replacing vi redo there. These are deliberate existing mappings.

## Keybinding Layers

| Operation | tmux | Herdr | Neovim |
| --- | --- | --- | --- |
| Prefix / leader | Ctrl+B | Ctrl+/ | Space |
| Side-by-side split | Prefix, `|` | Prefix, `|` | Ctrl+W, `v` |
| Stacked split | Prefix, `-` | Prefix, `-` (default) | Ctrl+W, `s` |
| Navigate panes/windows | Prefix, h/j/k/l | Prefix, h/j/k/l | Ctrl+W, h/j/k/l |
| Reload config | Prefix, r or R | Prefix, Shift+R | Restart editor |
| Find files | Shell Ctrl+T | Shell Ctrl+T | Ctrl+P or Space ff |
| Preview toggle | Shell fzf F4 | Shell fzf F4 | fzf-lua F4 |

tmux and Herdr use different split terminology, but these bindings have the
same visual result. Herdr lowercase prefix+r enters resize mode; do not
reassign it merely to match tmux reload. Its default prefix+- was not overridden.

Herdr Arrange 0.2.0 is enabled locally: prefix+m opens Arrange and prefix+Shift+M
opens Move Pane To. These actions move panes; they are not read-only pickers.
The installed plugin registry is runtime-managed, not a dotfile to edit manually.

Remaining keyboard caveats:

- Herdr Ctrl+/ depends on terminal encoding. Legacy terminals may send Ctrl+_
  instead. Keep the current prefix if it works; test before changing terminals
  or nesting multiplexers. Prefix twice forwards a literal prefix.
- iTerm's global Shift+Enter mapping sends a newline, indistinguishable from
  Ctrl+J downstream. It can execute a shell command rather than insert a soft
  newline. This existing iTerm preference was not changed.
- Neither saved iTerm profile sets an Option key to `+Esc`. Conventional Alt+C
  and other Meta shortcuts may require Escape followed by the key. Consider
  setting one Option key to `+Esc`, leaving the other for character composition.
- tmux h/j/k/l bindings are repeatable. For 500 ms after navigation, another
  matching letter can navigate again instead of being typed. Remove `-r` only
  if that trade-off is unwanted.
- fzf-lua's Telescope profile uses Ctrl+D to delete buffers in the buffer picker,
  but to scroll previews in other pickers. Dirty buffers have a save prompt.
- Neovim terminal-input mode exits with Ctrl+backslash, Ctrl+N. Escape is sent
  to the child application; no double-Escape override is configured.

## Search and Clipboard

Shell fzf (using fd), Neovim files, and Neovim live grep include hidden entries,
respect ignore files and exclude `.git`. Shell path pickers also include
directories; editor file pickers do not. All are cwd-based, not automatically
rooted at the Git repository. Existing fzf-lua hidden/ignore toggle actions are
retained alongside the Telescope profile's split and quickfix actions.
Symlink behavior remains backend-specific: Neovim's file picker lists symlink
entries, while default grep does not follow links. Enable `follow` only when
searching linked targets is intended.

The Telescope profile is part of fzf-lua, not a dependency on Telescope.
`:FzfLua` works before pressing a picker mapping. The editor intentionally has
no configured LSP, completion engine, formatter, or Mason installation.

Locally Neovim uses `pbcopy`/`pbpaste`; `unnamedplus` means ordinary deletes as
well as yanks affect the system clipboard. tmux uses `pbcopy` as its default
copy command when available, covering vi `y` and default copy-pipe bindings.
Otherwise tmux retains its internal copy buffer and existing terminal clipboard
policy. No extra OSC 52 trust permissions are enabled by this configuration.

The main Neovim clipboard setting is macOS-oriented. On provider-less SSH hosts,
unconditional `unnamedplus` prevents Neovim's automatic OSC 52 fallback; leave
`clipboard` empty and use explicit `"+y`, or configure a verified remote provider.
Do not force an OSC 52 provider or RGB capabilities for every terminal.

## Reloads and Checks

- Zim module changes: `zimfw install`, then a new shell. On macOS use
  `exec zsh -l` for login-shell behavior. Re-sourcing `.zshrc` does not reload
  already initialized Zim modules.
- Shell changes do not update already-running editors or a server's inherited
  environment. Check both new panes and new application processes.
- tmux prefix+r sources its config and runs plugins. Removing a binding from
  the file does not undo that binding in an already-running server.
- Herdr: run `herdr config check` before prefix+Shift+R. Do not stop the server
  just to validate configuration; existing pane processes belong to it.
- Zsh syntax: `zsh -fn ~/.zshrc` and `zsh -fn ~/.zimrc`.
- Completion permissions: `autoload -Uz compaudit; compaudit` in a shell.
- tmux terminfo: `infocmp tmux-256color`, including on SSH destinations.
- With an existing tmux server, inspect outer-terminal capabilities using
  `tmux -N list-clients -F '#{client_termname}: #{client_termfeatures}'` before
  adding terminal feature overrides.

The old `~/.p10k.zsh`, Zgen installation and historical editor state are not
loaded by the current setup. They were not deleted: inactivity alone does not
justify removing stored state or unrelated installations.
