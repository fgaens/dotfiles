# ============================================================================
# Lean Remote Bash Configuration
# ============================================================================

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ----------------------------------------------------------------------------
# History Configuration - Unified Across Sessions
# ----------------------------------------------------------------------------
HISTCONTROL=ignoredups:erasedups  # Ignore and erase duplicates
HISTSIZE=10000                     # In-memory history size
HISTFILESIZE=10000                 # History file size
shopt -s histappend                # Append to history file, don't overwrite

# Share history across sessions by appending and reloading after each command
_sync_history() {
  history -a  # Append current session's history to file
  history -r  # Read history file and append to current session
}

# ----------------------------------------------------------------------------
# Vi Mode
# ----------------------------------------------------------------------------
set -o vi

# ----------------------------------------------------------------------------
# Git Prompt Helper
# ----------------------------------------------------------------------------
git_prompt_info() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [[ -n "$branch" ]]; then
    local status=""
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
      status="*"
    fi
    echo " [git:${branch}${status}]"
  fi
}

# ----------------------------------------------------------------------------
# Command Duration Tracking
# ----------------------------------------------------------------------------
_timer_start() {
  timer_start=${timer_start:-$SECONDS}
}

_timer_stop() {
  local elapsed=$((SECONDS - timer_start))
  if [[ $elapsed -gt 1 ]]; then
    timer_show="[${elapsed}s] "
  else
    timer_show=""
  fi
  unset timer_start
}

trap '_timer_start' DEBUG
PROMPT_COMMAND="_timer_stop; $PROMPT_COMMAND"

# ----------------------------------------------------------------------------
# Prompt with Git, Duration, and Tmux Info
# ----------------------------------------------------------------------------
_prompt_command() {
  local tmux_info=""
  if [[ -n "$TMUX" ]]; then
    local session=$(tmux display-message -p '#S' 2>/dev/null)
    tmux_info="[tmux:${session}] "
  fi

  PS1="\[\033[36m\]${tmux_info}\[\033[32m\]\u@\h\[\033[00m\]:\[\033[34m\]\w\[\033[33m\]$(git_prompt_info)\[\033[35m\] ${timer_show}\[\033[00m\]\n\$ "
}

PROMPT_COMMAND="_sync_history; _prompt_command; $PROMPT_COMMAND"

# ----------------------------------------------------------------------------
# Aliases
# ----------------------------------------------------------------------------
alias ls='ls --color=auto 2>/dev/null || ls -G'
alias ll='ls -lah'
alias la='ls -A'
alias vim='vim'
alias ..='cd ..'
alias ...='cd ../..'

# ----------------------------------------------------------------------------
# Editor
# ----------------------------------------------------------------------------
export EDITOR='vim'
export VISUAL='vim'

# ----------------------------------------------------------------------------
# PATH
# ----------------------------------------------------------------------------
# Native OpenCode / Claude Code installers land here.
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"

# ----------------------------------------------------------------------------
# Better Tab Completion
# ----------------------------------------------------------------------------
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'

# ----------------------------------------------------------------------------
# Local Overrides (optional)
# ----------------------------------------------------------------------------
[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local
