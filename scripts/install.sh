#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Installing dotfiles..."

ln -sf "$DOTFILES_DIR/home/.zshrc" ~/.zshrc
ln -sf "$DOTFILES_DIR/home/.zshenv" ~/.zshenv
ln -sf "$DOTFILES_DIR/home/.gitconfig" ~/.gitconfig

mkdir -p ~/.config/zsh
for f in "$DOTFILES_DIR/config/zsh"/*.zsh; do
  filename=$(basename "$f")
  if [[ "$filename" != "secrets.zsh.example" ]]; then
    ln -sf "$f" ~/.config/zsh/"$filename"
  fi
done

if [[ ! -f ~/.config/zsh/secrets.zsh ]]; then
  cp "$DOTFILES_DIR/config/zsh/secrets.zsh.example" ~/.config/zsh/secrets.zsh
  chmod 600 ~/.config/zsh/secrets.zsh
  echo ""
  echo "Created ~/.config/zsh/secrets.zsh - edit with your API keys:"
  echo "  - RP_UUID_CREDENTIAL"
  echo "  - RP_QA_API_KEY"
fi

echo ""
echo "Dotfiles installed. Restart your shell or run: source ~/.zshrc"
