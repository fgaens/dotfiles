# AGENTS.md

This is the **global** OpenCode configuration for this machine (not a project repo). It lives at `~/.config/opencode/` — NOT `~/.opencode/`. Authored files are the `opencode` GNU Stow package in `~/dotfiles`. Validate edits against `https://opencode.ai/config.json` (the `$schema` declared in `opencode.jsonc`).

## Key files

- `opencode.jsonc` — main config: providers (`copilot`, `openai`, `xai` — auto-detected), the remote Atlassian MCP server, local Jenkins MCP, plugin loader, and global tool gating.
- `tui.jsonc` — TUI layer config; loads quota, oh-my-opencode-slim, and Herdr session plugins.
- `oh-my-opencode-slim.jsonc` — agent pantheon, presets (`personal`, `fednot`), council, multiplexer. JSONC takes precedence over `.json`.
- `preset-from-path.js` — picks the slim preset from the project path (`~/development/fednot/**` → `fednot`, otherwise `personal`). Must stay first in the `plugin` arrays so it runs before slim.
- `opencode-quota/quota-toast.jsonc` — auto-quota surface settings for the `@slkiser/opencode-quota` plugin.
- `plugins/herdr-agent-state.js` — Herdr OpenCode lifecycle integration (autodiscovered).
- `herdr-tui-session.js` — Herdr TUI session plugin, referenced from `tui.jsonc`.
- `skills/` — bundled oh-my-opencode-slim skills (`codemap`, `deepwork`, `reflect`, etc.).
- `command/handoff.md` — `/handoff` writes a paste-ready brief to `.opencode/handoff.md` for another harness (Claude Code, etc.).
- `package.json` / `package-lock.json` — npm deps for plugins; both gitignored (not version-controlled). Only `@opencode-ai/plugin` is pinned directly.

## The quota plugin (`@slkiser/opencode-quota`)

- Declared as an **npm `@latest` plugin** in BOTH `opencode.jsonc` and `tui.jsonc` — keep the two declarations in sync.
- Its behavior/visibility flags live in `opencode-quota/quota-toast.jsonc` (e.g. toast off, `tuiCommandDisplay: dialog`, compact status on, session token totals off).
- Auto-generated `// ...` comments in the jsonc files are written by this plugin — leave them.

## oh-my-opencode-slim

- Declared in BOTH `opencode.jsonc` and `tui.jsonc`. Built-in `explore`/`general` agents are disabled; slim's Orchestrator/Explorer/Oracle/Librarian/Designer/Fixer replace them.
- Path default: sessions under `~/development/fednot/` use `fednot` (OpenAI + xAI + GitHub Copilot). Everywhere else uses `personal` (OpenAI + xAI only; Copilot is disabled). `/preset` still overrides for the current session.
- Multiplexer is `auto` (Herdr 0.8.2 is installed). Launch OpenCode with an explicit `--port` inside Herdr/tmux so subagent panes can attach.
- Background orchestration needs `OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS=true` and `OPENCODE_ENABLE_EXA=1` (exported from `~/.zshrc`). Source that file or restart the terminal after install.
- Escape hatch: `OH_MY_OPENCODE_SLIM_DISABLE=1 opencode`. Do not let the slim installer `--reset` wipe MCP/tool guards.

## Read-only Rovo guard (do not accidentally undo)

The `tools` block in `opencode.jsonc` disables every Atlassian write/destructive tool (`atlassian_executeWrite`, `atlassian_executeDestructive`, `atlassian_create*`, `edit*`, `update*`, `transition*`, `add*`, `delete*`, `manage*`). Read and search stay enabled. Preserve this when editing the config.

## Read-only Jenkins guard (do not accidentally undo)

`mcp.jenkins` is a local `jenkins-mcp --read-only` process against `https://jenkins.fednot.be` (REST API; no Jenkins plugin required). Credentials come from macOS Keychain items `opencode-jenkins-user` and `opencode-jenkins-token`, loaded by `bin/jenkins-mcp.sh`. The `tools` block also disables write tools (`jenkins_build_item`, `jenkins_set_item_config`, `jenkins_stop_build`, `jenkins_set_node_config`, `jenkins_cancel_queue_item`). Preserve `--read-only` and those disables.

## Gotchas

- **No hot-reload**: config is loaded once at startup. After any edit, opencode must be quit and restarted to take effect.
- **Strict validation**: opencode hard-fails to start on an unknown or malformed config field. Prefer the authoritative schema over guessing shapes. If startup breaks, use `OPENCODE_DISABLE_PROJECT_CONFIG=1`, `OPENCODE_PURE=1` (skip external plugins), or `OPENCODE_CONFIG=/path/to/file` escape hatches.
- `mcp.atlassian` is remote and read-locked by the guard above; its write tools will not run for the agent.
- `mcp.jenkins` is local and read-locked by `--read-only` plus the tool disables above.
