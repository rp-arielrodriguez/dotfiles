# Dotfiles Agent Guide

This repository is public dotfiles. Keep it safe for public GitHub and easy to
install on a fresh developer machine.

## Source Of Truth

- Edit files in this repo, not the installed symlinks under `~`.
- `scripts/install.sh` is the only supported installer.
- `config/agents/AGENTS.md` is the global, tool-neutral agent instruction source.
- Tool-specific files are installed as symlinks to `config/agents/AGENTS.md`:
  - `~/.config/opencode/AGENTS.md`
  - `~/.agents/AGENTS.md`
  - `~/.codex/AGENTS.md`
  - `~/.claude/CLAUDE.md`
- Workspace/company/private instructions do not belong in this public repo unless
  they are intentionally public and generic. Prefer private mappings via
  `~/.config/agents/workspaces.tsv`.

## Public vs Private Boundary

Safe for this repo:
- Generic shell setup used on developer machines.
- Portable zsh modules and aliases.
- Generic agent behavior and installer mechanics.
- Templates and examples with placeholder values.

Keep out of this repo:
- Real secrets, tokens, API keys, credentials, private URLs, and customer data.
- Company-specific operational instructions.
- Workspace-specific instruction content that should not be public.
- Machine-specific paths except `~`, `$HOME`, or documented examples.

Private/local files currently expected by the installer:
- `~/.config/zsh/secrets.zsh`
- `~/.config/zsh/local.zsh`
- `~/.config/agents/workspaces.tsv`
- instruction files referenced by `~/.config/agents/workspaces.tsv`

## Installer Rules

Before changing installer behavior:
1. Run `bash -n scripts/install.sh`.
2. Run `./scripts/install.sh --dry-run`.
3. Inspect the exact human output.
4. Run `git diff --check`.

The dry-run output is part of the UX. Keep it compact and grouped with status
labels such as `[OK]`, `[LINK]`, `[RELINK]`, `[BACKUP]`, `[SKIP]`, `[CREATE]`.

Installer safety invariants:
- Existing real files are backed up before replacement unless their content is
  identical to the target source.
- Dry-run must not mutate files.
- Workspace target filenames must be relative, simple names. Reject absolute paths
  and `..`.
- Missing private workspace files should produce `[SKIP]`, not fail the install.

## Structure

- `home/`: files symlinked directly into `$HOME`.
- `bin/`: portable helper commands symlinked into `~/.local/bin`.
- `config/zsh/`: zsh modules symlinked into `~/.config/zsh`.
- `config/zsh/*.example`: templates copied once to private local files.
- `config/agents/AGENTS.md`: global agent instructions shared by Codex, Claude,
  OpenCode, and generic agent shims.
- `config/agents/workspaces/`: public docs/examples for workspace-level mappings.
- `scripts/install.sh`: idempotent installer and dry-run reporter.

## Common Tasks

### Add a global agent rule

Edit `config/agents/AGENTS.md`. Keep it generic and reusable. If the rule only
applies to one company, repo, or workspace, put it in a workspace instruction file
outside this public repo and add a private mapping.

### Add workspace instructions

Public mechanism:
- Update `config/agents/workspaces/README.md` or `links.tsv.example` only.

Private install on a machine:
- Put the private instruction file under `~/.config/agents/workspaces/<name>/`.
- Add a row to `~/.config/agents/workspaces.tsv`:

```text
~/path/to/workspace	~/.config/agents/workspaces/<name>/AGENTS.md	AGENTS.md,CLAUDE.md
```

Then run:

```bash
~/dotfiles/scripts/install.sh --dry-run
~/dotfiles/scripts/install.sh
```

### Add a zsh module

Add `config/zsh/<name>.zsh`. The installer links every `*.zsh` in that directory
except `.example` templates. Keep secrets and per-machine values in
`~/.config/zsh/secrets.zsh` or `~/.config/zsh/local.zsh`.

### Add machine-default developer tooling

Prefer portable detection:
- Use `$HOME`, not `/Users/<name>`.
- Check command paths before evaluating them.
- Support Apple Silicon Homebrew, Intel Homebrew, and Linuxbrew paths when relevant.
- Keep shell startup safe when optional tools are missing.
- Avoid expensive shell startup work unless lazy-loaded.

## Troubleshooting

Check installed symlinks:

```bash
realpath ~/.config/opencode/AGENTS.md ~/.agents/AGENTS.md ~/.codex/AGENTS.md ~/.claude/CLAUDE.md
```

Expected global target:

```text
~/dotfiles/config/agents/AGENTS.md
```

Check workspace mappings:

```bash
cat ~/.config/agents/workspaces.tsv
~/dotfiles/scripts/install.sh --dry-run
```

Common failures:
- `[SKIP] missing workspace`: create/clone the workspace first or remove the row.
- `[SKIP] missing workspace instruction file`: restore the private instruction file.
- `[RELINK]`: existing symlink points elsewhere; run the installer if the new target
  is correct.
- `[BACKUP]`: a real file would be moved aside. Inspect it before running without
  `--dry-run`.

## Commit Discipline

- Do not mention AI assistance in commits.
- Keep commits small: installer changes separate from shell preference changes when
  practical.
- Do not commit private overlay files from `~/.config/agents`.
