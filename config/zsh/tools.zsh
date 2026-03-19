# Lazy-load jenv (saves ~260ms startup)
export PATH="$HOME/.jenv/shims:${PATH}"
_jenv_lazy_init() {
  unfunction jenv 2>/dev/null
  eval "$(/opt/homebrew/bin/jenv init - zsh)"
}
jenv() { _jenv_lazy_init; jenv "$@" }

# Lazy-load mise
mise() {
  unset -f mise
  eval "$(mise activate zsh)"
  mise "$@"
}

# direnv
if command -v direnv >/dev/null; then
  eval "$(direnv hook zsh)"
fi

# fzf
{ source <(fzf --zsh); } 2>/dev/null

# gh copilot
eval "$(gh copilot alias -- zsh 2>/dev/null || true)"

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
