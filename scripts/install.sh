#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Installing dotfiles..."

# Symlink main config files
ln -sf "$DOTFILES_DIR/home/.zshrc" ~/.zshrc
ln -sf "$DOTFILES_DIR/home/.zshenv" ~/.zshenv
ln -sf "$DOTFILES_DIR/home/.gitconfig" ~/.gitconfig

# Create ~/.config/zsh and symlink modules
mkdir -p ~/.config/zsh
for f in "$DOTFILES_DIR/config/zsh"/*.zsh; do
  filename=$(basename "$f")
  if [[ "$filename" != "secrets.zsh.example" && "$filename" != "local.zsh.example" ]]; then
    ln -sf "$f" ~/.config/zsh/"$filename"
  fi
done

# Symlink functions directory
ln -sf "$DOTFILES_DIR/config/zsh/functions" ~/.config/zsh/functions

# Create secrets.zsh if not exists
if [[ ! -f ~/.config/zsh/secrets.zsh ]]; then
  cp "$DOTFILES_DIR/config/zsh/secrets.zsh.example" ~/.config/zsh/secrets.zsh
  chmod 600 ~/.config/zsh/secrets.zsh
  echo ""
  echo "Created ~/.config/zsh/secrets.zsh - edit with your API keys:"
  echo "  - RP_UUID_CREDENTIAL"
  echo "  - RP_QA_API_KEY"
fi

# Create local.zsh if not exists
if [[ ! -f ~/.config/zsh/local.zsh ]]; then
  cp "$DOTFILES_DIR/config/zsh/local.zsh.example" ~/.config/zsh/local.zsh
  echo ""
  echo "Created ~/.config/zsh/local.zsh - customize for this machine:"
  echo "  - Theme (spaceship, robbyrussell, etc.)"
  echo "  - Plugins"
  echo "  - Machine-specific settings"
fi

echo ""
echo "Dotfiles installed. Restart your shell or run: source ~/.zshrc"
