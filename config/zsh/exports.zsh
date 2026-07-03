export EDITOR=nvim
export GOPATH="$HOME/go"
export NIX_BUILD_GROUP_ID=30000

path_prepend() {
  [[ -d "$1" ]] && path=("$1" $path)
}

path_append() {
  [[ -d "$1" ]] && path=($path "$1")
}

path_prepend "$HOME/.local/bin"
path_prepend "$HOME/dotfiles/bin"
path_append "$GOPATH/bin"

case "$(uname -s)" in
  Darwin)
    export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}"
    path_prepend "/opt/homebrew/opt/make/libexec/gnubin"
    path_prepend "/usr/local/opt/make/libexec/gnubin"
    path_prepend "/opt/homebrew/opt/icu4c@78/bin"
    path_prepend "/usr/local/opt/icu4c@78/bin"
    ;;
  Linux)
    export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}"
    path_prepend "/home/linuxbrew/.linuxbrew/opt/make/libexec/gnubin"
    path_prepend "/home/linuxbrew/.linuxbrew/opt/icu4c@78/bin"
    ;;
esac

path_append "$ANDROID_SDK_ROOT/emulator"
path_append "$ANDROID_SDK_ROOT/platform-tools"
