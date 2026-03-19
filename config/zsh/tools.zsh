jenv() {
  unset -f jenv
  JENV_PATH="$(brew --prefix)/bin/jenv"
  [ -s "$JENV_PATH" ] && eval "$($JENV_PATH init -)"
  jenv "$@"
}

mise() {
  unset -f mise
  eval "$(mise activate zsh)"
  mise "$@"
}

{ source <(fzf --zsh); } 2>/dev/null

eval "$(gh copilot alias -- zsh 2>/dev/null || true)"

alias claude='NODE_TLS_REJECT_UNAUTHORIZED=0 claude'
alias claude-work="CLAUDE_CONFIG_DIR=~/.claude-work claude"
