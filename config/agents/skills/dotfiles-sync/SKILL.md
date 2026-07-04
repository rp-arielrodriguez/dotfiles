---
name: dotfiles-sync
description: Safely update, install, or troubleshoot Ariel's dotfiles across macOS and Linux machines. Use when the user asks to sync dotfiles, update a machine from the dotfiles repo, bootstrap dotfiles on a new machine, verify installed symlinks, or modify the dotfiles installer/update workflow.
---

# Dotfiles Sync

## Overview

Use the dotfiles repo as the source of truth and `scripts/sync.sh` as the normal
machine update entrypoint. Keep public dotfiles generic; keep secrets and private
workspace instructions outside the repo unless explicitly intended for public use.

## Existing Machine

1. Locate the repo, normally `~/dotfiles`, and run:

   ```bash
   cd ~/dotfiles
   git status --short --branch
   ./scripts/sync.sh
   ```

2. If `sync.sh` blocks on local changes, stop and report `git status --short`.
   Do not stash, commit, reset, or discard changes unless the user asks.

3. If the dry-run is clean, apply the update:

   ```bash
   ./scripts/sync.sh --apply
   ```

4. Report the final status and any warnings.

Use `./scripts/sync.sh --no-pull` only when testing local installer changes in a
dirty dotfiles checkout. Use `--allow-warnings` only after inspecting and
explaining risky dry-run labels such as `[BACKUP]`, `[RELINK]`, `[REPLACE]`, or
`[SKIP]`.

## New Machine

If `~/dotfiles` does not exist:

```bash
git clone git@github.com:rp-arielrodriguez/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/install.sh --dry-run
./scripts/install.sh
```

If SSH authentication fails because the user is unavailable or credentials are
locked, stop and report the blocker. Do not switch credential methods without
explicit user confirmation.

## Editing Dotfiles

Before editing, read `~/dotfiles/AGENTS.md`. Edit sources in the repo, not
installed symlinks under `~`.

Validation for installer or sync workflow changes:

```bash
bash -n scripts/install.sh
bash -n scripts/sync.sh
./scripts/install.sh --dry-run
./scripts/sync.sh --no-pull
git diff --check
```

Then run `./scripts/sync.sh --no-pull --apply` only when the dry-run is clean or
the user explicitly accepts the warnings.

## Installed Targets

Shared agent instructions are symlinked from `config/agents/AGENTS.md` to:

- `~/.config/opencode/AGENTS.md`
- `~/.agents/AGENTS.md`
- `~/.codex/AGENTS.md`
- `~/.claude/CLAUDE.md`

Shared skills are symlinked from `config/agents/skills/<skill>` to:

- `~/.config/opencode/skills/<skill>`
- `~/.agents/skills/<skill>`
- `~/.codex/skills/<skill>`
- `~/.claude/skills/<skill>`

Do not edit installed targets directly. Change the dotfiles source and re-run the
installer/sync command.
