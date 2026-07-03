# Lazy-load jenv (saves ~260ms startup)
export PATH="$HOME/.jenv/shims:${PATH}"
_jenv_lazy_init() {
  unfunction jenv 2>/dev/null
  if command -v jenv >/dev/null 2>&1; then
    eval "$(command jenv init - zsh)"
  fi
}
jenv() { _jenv_lazy_init; jenv "$@" }

# Lazy-load mise
mise() {
  unset -f mise
  if command -v mise >/dev/null 2>&1; then
    eval "$(command mise activate zsh)"
  fi
  mise "$@"
}

# direnv
if command -v direnv >/dev/null; then
  eval "$(direnv hook zsh)"
fi

# fzf
if command -v fzf >/dev/null 2>&1; then
  { source <(fzf --zsh); } 2>/dev/null
fi

# gh copilot
if command -v gh >/dev/null 2>&1; then
  eval "$(gh copilot alias -- zsh 2>/dev/null || true)"
fi

# Autoload custom functions from ~/.config/zsh/functions
autoload -Uz ~/.config/zsh/functions/*(:t)

# edit-command-line (bind 'v' in vicmd to edit command in $EDITOR)
if [[ -o interactive ]]; then
  autoload -U edit-command-line
  zle -N edit-command-line
  bindkey -M vicmd v edit-command-line
fi

# Claude aliases
alias claude='NODE_TLS_REJECT_UNAUTHORIZED=0 claude'
alias claude-work="CLAUDE_CONFIG_DIR=~/.claude-work claude"
