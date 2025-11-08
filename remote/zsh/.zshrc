# ============================================================================
# Lean Remote ZSH Configuration
# ============================================================================

# ----------------------------------------------------------------------------
# History Configuration - Unified Across Sessions
# ----------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Share history across all sessions in real-time
setopt SHARE_HISTORY              # Share history between all sessions
setopt INC_APPEND_HISTORY         # Write to history immediately, not on shell exit
setopt HIST_IGNORE_ALL_DUPS       # Remove older duplicate entries from history
setopt HIST_FIND_NO_DUPS          # Don't show duplicates when searching
setopt HIST_REDUCE_BLANKS         # Remove extra blanks from commands
setopt HIST_VERIFY                # Show command with history expansion before running

# ----------------------------------------------------------------------------
# Vi Mode
# ----------------------------------------------------------------------------
bindkey -v
export KEYTIMEOUT=1  # Faster vi mode switching

# Remove path separator from WORDCHARS for better word navigation
WORDCHARS=${WORDCHARS//[\/]}

# ----------------------------------------------------------------------------
# Completion System
# ----------------------------------------------------------------------------
autoload -Uz compinit
compinit -d ~/.zcompdump-remote

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Load additional completions if available
if [[ -d ~/.zsh-plugins/zsh-completions/src ]]; then
  fpath=(~/.zsh-plugins/zsh-completions/src $fpath)
fi

# ----------------------------------------------------------------------------
# Prompt with Git, Duration, and Tmux Info
# ----------------------------------------------------------------------------

# Git prompt info
git_prompt_info() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [[ -n "$branch" ]]; then
    local status=""
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
      status="*"
    fi
    echo " %F{yellow}[git:${branch}${status}]%f"
  fi
}

# Command duration tracking
preexec() {
  cmd_start=$SECONDS
}

precmd() {
  if [[ -n $cmd_start ]]; then
    local elapsed=$((SECONDS - cmd_start))
    if [[ $elapsed -gt 1 ]]; then
      cmd_duration=" %F{magenta}[${elapsed}s]%f"
    else
      cmd_duration=""
    fi
    unset cmd_start
  fi

  # Update prompt
  _prompt_set
}

_prompt_set() {
  local tmux_info=""
  if [[ -n "$TMUX" ]]; then
    local session=$(tmux display-message -p '#S' 2>/dev/null)
    tmux_info="%F{cyan}[tmux:${session}]%f "
  fi

  PROMPT="${tmux_info}%F{green}%n@%m%f:%F{blue}%~%f$(git_prompt_info)${cmd_duration}
%# "
}

# Initialize prompt
_prompt_set

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
# Load Plugins (if available)
# ----------------------------------------------------------------------------
PLUGIN_DIR=~/.zsh-plugins

# Syntax Highlighting
if [[ -f $PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source $PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
fi

# Autosuggestions
if [[ -f $PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source $PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
fi

# History Substring Search
if [[ -f $PLUGIN_DIR/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
  source $PLUGIN_DIR/zsh-history-substring-search/zsh-history-substring-search.zsh
  # Bind in vi-mode
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
fi

# ----------------------------------------------------------------------------
# Local Overrides (optional)
# ----------------------------------------------------------------------------
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
