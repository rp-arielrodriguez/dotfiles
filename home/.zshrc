export ZSH="$HOME/.oh-my-zsh"
ZSH_DISABLE_COMPFIX="true"
DISABLE_AUTO_UPDATE="true"

# Load machine-specific early config (theme, plugins, fpath)
[[ -f ~/.config/zsh/local.zsh ]] && source ~/.config/zsh/local.zsh

source $ZSH/oh-my-zsh.sh

# Load all zsh modules (alphabetically, secrets last)
for f in ~/.config/zsh/*.zsh; do source "$f"; done

# SDKMAN must be last
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
