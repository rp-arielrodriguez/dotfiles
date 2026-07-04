#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APPLY=false
PULL=true
ALLOW_WARNINGS=false

usage() {
  cat <<'EOF'
Usage: sync.sh [--apply] [--no-pull] [--allow-warnings]

Safely update this machine from the dotfiles repo.

Default behavior:
  1. Refuse to pull if the dotfiles worktree is dirty.
  2. Pull the current branch with --ff-only.
  3. Run the visual installer dry-run.
  4. Stop before mutating files.

Options:
  --apply           Run the real installer after a clean dry-run
  --no-pull         Skip git pull, useful when testing local changes
  --allow-warnings  Allow install even if dry-run shows BACKUP/RELINK/REPLACE/SKIP
  --help, -h        Show this help
EOF
}

status() {
  local label="$1"
  local message="$2"

  printf '[%-7s] %s\n' "$label" "$message"
}

for arg in "$@"; do
  case "$arg" in
    --apply)
      APPLY=true
      ;;
    --no-pull)
      PULL=false
      ;;
    --allow-warnings)
      ALLOW_WARNINGS=true
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

cd "$DOTFILES_DIR"

if [[ "$PULL" == true ]]; then
  status "CHECK" "dotfiles git status"
  if [[ -n "$(git status --porcelain)" ]]; then
    status "BLOCK" "dotfiles worktree has local changes; commit/stash them or rerun with --no-pull"
    git status --short
    exit 1
  fi

  status "FETCH" "origin"
  git fetch origin

  upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
  if [[ -z "$upstream" ]]; then
    status "SKIP" "current branch has no upstream"
  else
    status "PULL" "$upstream --ff-only"
    git pull --ff-only
  fi
else
  status "SKIP" "git pull disabled by --no-pull"
fi

dry_run_output="$(mktemp)"
trap 'rm -f "$dry_run_output"' EXIT

status "DRYRUN" "scripts/install.sh --dry-run"
"$DOTFILES_DIR/scripts/install.sh" --dry-run | tee "$dry_run_output"

if grep -E '\[(BACKUP|RELINK|REPLACE|SKIP)[[:space:]]*\]' "$dry_run_output" >/dev/null; then
  if [[ "$ALLOW_WARNINGS" != true ]]; then
    status "BLOCK" "dry-run contains BACKUP/RELINK/REPLACE/SKIP; inspect output or rerun with --allow-warnings"
    exit 2
  fi

  status "WARN" "continuing despite dry-run warnings because --allow-warnings was passed"
fi

if [[ "$APPLY" != true ]]; then
  status "DONE" "plan only; no files changed. Run scripts/sync.sh --apply to install."
  exit 0
fi

status "APPLY" "scripts/install.sh"
"$DOTFILES_DIR/scripts/install.sh"
status "DONE" "dotfiles synced"
