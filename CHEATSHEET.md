# Cheatsheet

[Multiplexers](#multiplexers-tmux--herdr) · [Zsh](#zsh) · [Neovim](#neovim) · [Claude Code](#claude-code)

---

## Multiplexers (tmux / Herdr)

**Prefix** `Ctrl+/` in both. Press prefix, release, then the key. Prefix twice sends a literal `Ctrl+/`.

| Herdr | tmux |
| --- | --- |
| Tab | Window |
| Space | Session |

### Tabs

| Key | Action | In |
| --- | --- | --- |
| `c` | New | both |
| `n` / `p` | Next / previous | both |
| `1`–`9` | Jump to | both |
| `^` | Last | tmux |
| `,` / `&` / `w` | Rename / kill / list | tmux |
| `Shift+T` / `Shift+X` | Rename / close | Herdr |

### Panes

| Key | Action | In |
| --- | --- | --- |
| `\|` / `-` | Split side / stacked | both |
| `h` `j` `k` `l` | Navigate | both |
| `x` / `z` | Close / zoom | both |
| `Tab` / `Shift+Tab` | Cycle | Herdr |
| `r` | Resize mode | Herdr |
| `m` / `Shift+M` | Arrange / move pane to | Herdr |

### Spaces

| Key | Action | In |
| --- | --- | --- |
| `(` / `)` | Previous / next | both |
| `s` / `$` | List / rename | tmux |
| `w` / `g` | Picker / goto | Herdr |
| `Shift+N` / `Shift+W` / `Shift+D` | New / rename / close | Herdr |

### Copy, detach, config

| Key | Action | In |
| --- | --- | --- |
| `[` | Copy mode (`v` select, `y` copy) | both |
| `d` | Detach | tmux |
| `q` | Detach | Herdr |
| `e` `b` `s` | Scrollback / sidebar / settings | Herdr |
| `F` | tmux-fzf | tmux |
| `r` / `R` / `I` | Reload / sensible reload / TPM install | tmux |
| `Shift+R` | Reload | Herdr |
| `?` | All bindings | Herdr |

---

## Zsh

Vi mode. `Esc` = command mode.

### History

| Key | Action |
| --- | --- |
| `j` / `k` (command mode) | Substring history |
| Up / Down | Ordinary history |
| `Ctrl+R` | fzf history |

### fzf

| Key | Action |
| --- | --- |
| `Ctrl+T` | Path picker |
| `Alt+C` | `cd` picker (`Esc` `c` if Alt fails) |
| `Tab` | Fuzzy completion |
| `F4` | Toggle preview |

### Line editing

| Key | Action |
| --- | --- |
| `Ctrl+X` `Ctrl+E` | Edit line in Neovim |
| Right / End | Accept autosuggestion |

---

## Neovim

Leader = `Space`.

| Key | Action |
| --- | --- |
| `Ctrl+P` / `Space` `ff` | Files |
| `Space` `fg` | Grep |
| `Space` `fb` | Buffers |
| `Space` `fo` | Recent files |

---

## Claude Code

### `/code-review`

```
/code-review [level] [flags] [target]
```

**Targets**

| Review | Command |
| --- | --- |
| Uncommitted + unpushed commits | `/code-review high` |
| Current branch vs master | `/code-review high master...HEAD` |
| Branch not checked out | `/code-review high master...origin/feature/FOR-123` |
| PR | `/code-review high 123` |
| Single file | `/code-review high src/main/java/Foo.java` |

**Levels**

| Level | Behaviour |
| --- | --- |
| `low` `medium` | Fewer, high-confidence findings |
| `high` `xhigh` `max` | Broader coverage, may include uncertain findings |
| `ultra` | Multi-agent review in the cloud (billed) |
| _(none)_ | Reuses the last level typed, even from an earlier session |

**Flags**

| Flag | Effect | Example |
| --- | --- | --- |
| `--fix` | Apply findings to the working tree | `/code-review high --fix master...HEAD` |
| `--comment` | Post findings as inline PR comments | `/code-review high --comment 123` |
| `--post` | `ultra` + GitHub PR: post findings as one PR comment | `/code-review ultra --post 123` |
| `--no-post` | `ultra` + GitHub PR: hide the post option | `/code-review ultra --no-post 123` |

**Gotchas**

- No target = commits ahead of **upstream** + uncommitted changes. Branch without upstream → base undocumented; pass a range.
- Branch not checked out → `git fetch` first so the ref exists.
- PR by number only; PR URLs are not a documented target.
- `/code-review ultra` (no target) = current branch vs default branch + uncommitted changes.

Docs: https://code.claude.com/docs/en/code-review.md
