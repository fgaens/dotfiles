---
description: Write a paste-ready session brief for another harness (Claude Code, Codex, Cursor). Usage: /handoff or /handoff continue the Pi nginx setup
---

Create a handoff brief for another coding agent that has **no** access to this OpenCode session.

Focus (optional): $ARGUMENTS

Workspace context (injected):
- cwd: !`pwd`
- git: !`git status -sb 2>/dev/null; echo '---'; git diff --stat 2>/dev/null; echo '---'; git log -5 --oneline 2>/dev/null`

Rules:
- Write for a capable agent, not a human manager. No recap of this chat, no tool logs, no praise.
- Be concrete: absolute or repo-relative paths, commands, decisions, and unfinished work.
- If $ARGUMENTS is non-empty, bias the brief toward that; otherwise cover the whole session.
- Omit secrets, tokens, and unrelated personal files.
- If something is unknown, say so instead of guessing.

Write **two** things:

1. Save the brief to `.opencode/handoff.md` in the project cwd (create `.opencode/` if needed). Overwrite any previous handoff. This path is gitignored.

2. In the chat, print only:
   - the path of the file
   - a one-line paste hint: `claude` then `@.opencode/handoff.md` (or paste the file)
   - the full brief in one fenced markdown block so it can be copied without the file

Brief structure (use these headings):

# Handoff

## Goal
What the user wants, in one short paragraph.

## Done
Bullet list of completed work. Name files and behaviors, not process.

## Not done / next
Exact next actions. Ordered.

## Key files
Path — why it matters.

## Decisions
Choices that the next agent must not silently reverse.

## Verify
Commands to run, or what “working” looks like.

## Constraints
Repo rules, deploy targets, “don’t touch X”.
