export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
ZSH_DISABLE_COMPFIX="true"
DISABLE_AUTO_UPDATE="true"
source $ZSH/oh-my-zsh.sh

for f in ~/.config/zsh/*.zsh; do source "$f"; done

fpath=(~/.docker/completions $fpath)

[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
