export ZSH="$HOME/.oh-my-zsh"
ZSH_DISABLE_COMPFIX="true"
DISABLE_AUTO_UPDATE="true"

for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  if [[ -x "$brew_bin" ]]; then
    eval "$("$brew_bin" shellenv)"
    break
  fi
done

# Load machine-specific early config (theme, plugins, fpath)
[[ -f ~/.config/zsh/local.zsh ]] && source ~/.config/zsh/local.zsh

if [[ -d "$HOME/.docker/completions" ]]; then
  fpath=("$HOME/.docker/completions" $fpath)
fi

if [[ -s "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# Load all zsh modules (alphabetically, secrets last)
for f in ~/.config/zsh/*.zsh; do source "$f"; done

# SDKMAN must be last
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
