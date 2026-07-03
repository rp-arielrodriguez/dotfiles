export ZSH="$HOME/.oh-my-zsh"
ZSH_DISABLE_COMPFIX="true"
DISABLE_AUTO_UPDATE="true"

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Load machine-specific early config (theme, plugins, fpath)
[[ -f ~/.config/zsh/local.zsh ]] && source ~/.config/zsh/local.zsh

if [[ -d "$HOME/.docker/completions" ]]; then
  fpath=("$HOME/.docker/completions" $fpath)
fi

source $ZSH/oh-my-zsh.sh

# Load all zsh modules (alphabetically, secrets last)
for f in ~/.config/zsh/*.zsh; do source "$f"; done

# SDKMAN must be last
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
