---
name: codex-usage
description: Show Codex rate limits, plan and credits for the currently logged-in Codex account. Use when the user asks about their Codex usage, quota, rate limits, or how much Codex they have left.
argument-hint: '[--json]'
disable-model-invocation: true
allowed-tools: Bash(node:*)
---

!`node "$HOME/.claude/skills/codex-usage/codex-usage.mjs" $ARGUMENTS`

Present the command output above to the user as-is. Do not summarize, reformat or condense it.
