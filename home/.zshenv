export PATH="$PATH:$HOME/.recarga/bin"
export PATH="$HOME/.jenv/bin:$PATH"
export NVM_DIR="$HOME/.nvm"

# Lazy-load NVM: only sources nvm.sh on first use
_nvm_lazy_load() {
  unfunction nvm node npm npx 2>/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
}
nvm()  { _nvm_lazy_load; nvm  "$@" }
node() { _nvm_lazy_load; node "$@" }
npm()  { _nvm_lazy_load; npm  "$@" }
npx()  { _nvm_lazy_load; npx  "$@" }

[ -s "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
