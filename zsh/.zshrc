setopt HIST_IGNORE_ALL_DUPS

typeset -U path PATH fpath FPATH
# Discard the literal path exported by the previous configuration.
path=(${path:#'~/.local/bin'})

bindkey -v

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=12,bg=8,underline'
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# ------------------
# Initialize modules
# ------------------
# Zim's completion module calls compinit. Re-sourcing this file would warn and
# call it again; skip if already loaded. On macOS reload with `exec zsh -l`.

if (( ! $+_ZIM_SOURCED )); then
  () {
    ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
    # Rebuild module paths locally instead of inheriting removed Zim modules.
    fpath=(${fpath:#${ZIM_HOME}/modules/*})
    # macOS path_helper can reorder PATH even when Homebrew is inherited.
    if [[ -n ${HOMEBREW_PREFIX} ]]; then
      path=("${HOMEBREW_PREFIX}/bin" "${HOMEBREW_PREFIX}/sbin" ${path})
      fpath=("${HOMEBREW_PREFIX}/share/zsh/site-functions" ${fpath})
    fi
    # The fzf module appends to these exported options on every new shell.
    unset FZF_CTRL_T_OPTS FZF_ALT_C_OPTS
    if [[ ! -s ${ZIM_HOME}/zimfw.zsh ]]; then
      mkdir -p "${ZIM_HOME}" || return 1
      local download
      download=$(mktemp "${ZIM_HOME}/zimfw.zsh.XXXXXX") || return 1
      if curl -fsSL --connect-timeout 10 --max-time 60 -o "${download}" \
          https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh \
          && zsh -n "${download}"; then
        mv -f "${download}" "${ZIM_HOME}/zimfw.zsh" || return 1
      else
        rm -f "${download}"
        return 1
      fi
    fi
    if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
      source "${ZIM_HOME}/zimfw.zsh" init || return 1
    fi
    source "${ZIM_HOME}/init.zsh" || return 1
    typeset -g _ZIM_SOURCED=1
  } || print -u2 'Zim initialization failed; fix the error and start a new shell.'
fi

# Keep completion paths local; child shells load their own module list.
typeset +x FPATH

# ------------------------------
# FZF
# ------------------------------
# Match Neovim: include hidden files, respect ignore files, exclude .git.
() {
  local fd_cmd=${commands[fd]:-${commands[fdfind]}}
  [[ -n ${fd_cmd} ]] || return 0
  export FZF_DEFAULT_COMMAND="${(q)fd_cmd} --hidden --exclude .git --type f --type d"
  export FZF_CTRL_T_COMMAND=${FZF_DEFAULT_COMMAND}
  export FZF_ALT_C_COMMAND="${(q)fd_cmd} --hidden --exclude .git --type d"
  _fzf_compgen_path() { command ${commands[fd]:-${commands[fdfind]}} --hidden --exclude .git --type f --type d . "${1}" }
  _fzf_compgen_dir() { command ${commands[fd]:-${commands[fdfind]}} --hidden --exclude .git --type d . "${1}" }
}
# F4 also toggles previews in fzf-lua; Ctrl-/ belongs to Herdr.
export FZF_ALT_C_OPTS=${FZF_ALT_C_OPTS//ctrl-\/:toggle-preview/f4:toggle-preview}
[[ -n ${FZF_CTRL_T_OPTS} ]] && export FZF_CTRL_T_OPTS=${FZF_CTRL_T_OPTS//ctrl-\/:toggle-preview/f4:toggle-preview}

# ------------------------------
# HISTORY SEARCH VIM KEYBINDINGS
# ------------------------------
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# ------------------------------
# EXPORTS
# ------------------------------
export EDITOR='nvim'
export VISUAL=$EDITOR
path+=("$HOME/Library/Application Support/JetBrains/Toolbox/scripts" "$HOME/.lmstudio/bin")

# ------------------------------
# ALIASES
# ------------------------------
alias vim="nvim"
alias oc="opencode --auto"

# ------------------------------
# RBENV
# ------------------------------
(( ${+commands[rbenv]} )) && eval "$(rbenv init - --no-rehash zsh)"

# ------------------------------
# SDKMAN
# ------------------------------
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
# SDKMAN only inserts missing paths; restore their priority after path_helper.
if [[ -n ${SDKMAN_CANDIDATES_DIR} ]]; then
  path=(${(M)path:#${SDKMAN_CANDIDATES_DIR}/*} ${path})
fi

path=("$HOME/.local/bin" ${path})
