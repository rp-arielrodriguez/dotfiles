#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN=false

usage() {
  cat <<'EOF'
Usage: install.sh [--dry-run|-n]

Options:
  --dry-run, -n  Print planned changes without modifying files
  --help, -h     Show this help
EOF
}

for arg in "$@"; do
  case "$arg" in
    --dry-run|-n)
      DRY_RUN=true
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ "$DRY_RUN" == true ]]; then
  echo "Dry-run: inspecting dotfiles installation plan..."
else
  echo "Installing dotfiles..."
fi

section() {
  echo ""
  echo "== $1 =="
}

status() {
  local label="$1"
  local message="$2"

  printf '  [%-7s] %s\n' "$label" "$message"
}

ensure_dir() {
  local dir="$1"

  if [[ "$DRY_RUN" == true ]]; then
    if [[ ! -d "$dir" ]]; then
      status "MKDIR" "$dir"
    fi
    return 0
  fi

  mkdir -p "$dir"
}

link_config() {
  local source="$1"
  local target="$2"

  ensure_dir "$(dirname "$target")"

  if [[ -e "$target" && ! -L "$target" ]]; then
    if [[ -e "$source" ]] && cmp -s "$source" "$target"; then
      if [[ "$DRY_RUN" == true ]]; then
        status "REPLACE" "$target -> $source (identical file)"
        return 0
      fi

      rm "$target"
    else
      local backup="${target}.backup-$(date +%Y%m%d%H%M%S)"
      if [[ "$DRY_RUN" == true ]]; then
        status "BACKUP" "$target -> $backup"
        status "LINK" "$target -> $source"
        return 0
      fi

      mv "$target" "$backup"
      status "BACKUP" "$target -> $backup"
    fi
  fi

  if [[ "$DRY_RUN" == true ]]; then
    if [[ -L "$target" ]]; then
      local current
      current="$(readlink "$target")"
      if [[ "$current" == "$source" ]]; then
        status "OK" "$target -> $source"
      else
        status "RELINK" "$target -> $source (currently $current)"
      fi
    elif [[ -e "$target" ]]; then
      status "LINK" "$target -> $source"
    else
      status "LINK" "$target -> $source"
    fi
    return 0
  fi

  ln -sfn "$source" "$target"
  status "LINK" "$target -> $source"
}

expand_path() {
  local path="$1"

  case "$path" in
    "~")
      printf '%s\n' "$HOME"
      ;;
    "~/"*)
      printf '%s/%s\n' "$HOME" "${path#\~/}"
      ;;
    *)
      printf '%s\n' "$path"
      ;;
  esac
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s\n' "$value"
}

install_workspace_links() {
  local registry="$1"

  [[ -f "$registry" ]] || return 0

  status "SOURCE" "$registry"

  while IFS=$'\t' read -r workspace source targets extra || [[ -n "${workspace:-}" ]]; do
    workspace="$(trim "${workspace:-}")"
    source="$(trim "${source:-}")"
    targets="$(trim "${targets:-}")"

    [[ -z "$workspace" || "${workspace:0:1}" == "#" ]] && continue

    if [[ -n "${extra:-}" ]]; then
      status "SKIP" "invalid mapping with too many columns: $workspace"
      continue
    fi

    if [[ -z "$source" ]]; then
      status "SKIP" "missing instruction file column: $workspace"
      continue
    fi

    if [[ -z "$targets" ]]; then
      targets="AGENTS.md,CLAUDE.md"
    fi

    workspace="$(expand_path "$workspace")"
    source="$(expand_path "$source")"

    if [[ ! -d "$workspace" ]]; then
      status "SKIP" "missing workspace: $workspace"
      continue
    fi

    if [[ ! -f "$source" ]]; then
      status "SKIP" "missing workspace instruction file: $source"
      continue
    fi

    IFS=',' read -ra target_names <<< "$targets"
    for target_name in "${target_names[@]}"; do
      target_name="$(trim "$target_name")"

      if [[ -z "$target_name" || "$target_name" == /* || "$target_name" == *..* ]]; then
        status "SKIP" "unsafe workspace target '$target_name' for $workspace"
        continue
      fi

      link_config "$source" "$workspace/$target_name"
    done
  done < "$registry"
}

# Symlink main config files
section "Shell home files"
link_config "$DOTFILES_DIR/home/.zshrc" ~/.zshrc
link_config "$DOTFILES_DIR/home/.zshenv" ~/.zshenv
link_config "$DOTFILES_DIR/home/.gitconfig" ~/.gitconfig

# Create ~/.config/zsh and symlink modules
section "Zsh modules"
ensure_dir ~/.config/zsh
for f in "$DOTFILES_DIR/config/zsh"/*.zsh; do
  filename=$(basename "$f")
  if [[ "$filename" != "secrets.zsh.example" && "$filename" != "local.zsh.example" ]]; then
    link_config "$f" ~/.config/zsh/"$filename"
  fi
done

# Symlink functions directory
link_config "$DOTFILES_DIR/config/zsh/functions" ~/.config/zsh/functions

# Symlink shared agent instructions from a tool-neutral source
section "Global agent instructions"
AGENT_INSTRUCTIONS="$DOTFILES_DIR/config/agents/AGENTS.md"
link_config "$AGENT_INSTRUCTIONS" ~/.config/opencode/AGENTS.md
link_config "$AGENT_INSTRUCTIONS" ~/.agents/AGENTS.md
link_config "$AGENT_INSTRUCTIONS" ~/.codex/AGENTS.md
link_config "$AGENT_INSTRUCTIONS" ~/.claude/CLAUDE.md

section "Workspace agent instructions"
shopt -s nullglob
workspace_registries=(
  "$DOTFILES_DIR/config/agents/workspaces/links.tsv"
  "$DOTFILES_DIR"/config/agents/workspaces/*.local.tsv
  "$HOME/.config/agents/workspaces.tsv"
)
for registry in "${workspace_registries[@]}"; do
  install_workspace_links "$registry"
done
shopt -u nullglob

# Create secrets.zsh if not exists
if [[ ! -f ~/.config/zsh/secrets.zsh ]]; then
  section "Local-only files"
  if [[ "$DRY_RUN" == true ]]; then
    status "CREATE" "~/.config/zsh/secrets.zsh from template"
  else
    cp "$DOTFILES_DIR/config/zsh/secrets.zsh.example" ~/.config/zsh/secrets.zsh
    chmod 600 ~/.config/zsh/secrets.zsh
    status "CREATE" "~/.config/zsh/secrets.zsh"
  fi
fi

# Create local.zsh if not exists
if [[ ! -f ~/.config/zsh/local.zsh ]]; then
  if [[ -f ~/.config/zsh/secrets.zsh ]]; then
    section "Local-only files"
  fi
  if [[ "$DRY_RUN" == true ]]; then
    status "CREATE" "~/.config/zsh/local.zsh from template"
  else
    cp "$DOTFILES_DIR/config/zsh/local.zsh.example" ~/.config/zsh/local.zsh
    status "CREATE" "~/.config/zsh/local.zsh"
  fi
fi

echo ""
if [[ "$DRY_RUN" == true ]]; then
  echo "Dry-run complete. No files were changed."
else
  echo "Dotfiles installed. Restart your shell or run: source ~/.zshrc"
fi
