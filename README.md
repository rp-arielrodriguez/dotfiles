# Dotfiles

Personal dotfiles for Ariel Rodriguez.

Agent maintainers: read [`AGENTS.md`](AGENTS.md) first for source-of-truth,
privacy, installer, and troubleshooting rules.

## Install

```bash
git clone git@github.com:rp-arielrodriguez/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/install.sh
```

Update an existing machine safely:

```bash
~/dotfiles/scripts/sync.sh
~/dotfiles/scripts/sync.sh --apply
```

Preview without changing files:

```bash
./scripts/install.sh --dry-run
```

## Structure

```
~/dotfiles/
├── bin/                     # Portable helper commands symlinked to ~/.local/bin
│   └── gh-git-credential
├── home/                    # Symlinked to ~
│   ├── .zshrc
│   ├── .zshenv
│   └── .gitconfig
├── config/tmux/
│   └── tmux.conf            # Portable tmux config and TPM plugin list
├── config/zsh/              # Modular zsh config
│   ├── exports.zsh
│   ├── git.zsh
│   ├── adb.zsh
│   ├── work.zsh
│   ├── tools.zsh
│   ├── functions/           # Custom autoloaded functions
│   │   └── json2query
│   ├── local.zsh.example    # Template for machine-specific
│   └── secrets.zsh.example  # Template for API keys
├── config/agents/           # Shared agent config
│   ├── AGENTS.md            # Tool-neutral instructions for Codex/Claude/OpenCode
│   └── skills/              # Shared public skills for supported agents
└── scripts/
    ├── install.sh
    └── sync.sh
```

## After Install

1. Edit `~/.config/zsh/secrets.zsh` with your API keys
2. Edit `~/.config/zsh/local.zsh` for machine-specific settings (theme, plugins)
3. Install TPM if you want tmux plugins: `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
4. Restart your shell: `exec zsh`

## Platform Support

The installer and agent config support macOS and Linux. Shell startup detects:

- Homebrew on Apple Silicon: `/opt/homebrew`
- Homebrew on Intel macOS: `/usr/local`
- Linuxbrew: `/home/linuxbrew/.linuxbrew`
- Android SDK on macOS: `~/Library/Android/sdk`
- Android SDK on Linux: `~/Android/Sdk`

Oh My Zsh is optional for shell startup safety, but recommended because some git
aliases expect Oh My Zsh's git helpers and plugins. Tmux config is plain tmux and
uses TPM-compatible plugin declarations for macOS/Linux portability.

## Agent Config

Shared agent instructions live in `config/agents/AGENTS.md`. Tool-specific config
files are symlinks to that neutral source:

| Tool | Symlink |
|------|---------|
| OpenCode | `~/.config/opencode/AGENTS.md` |
| Generic agents | `~/.agents/AGENTS.md` |
| Codex | `~/.codex/AGENTS.md` |
| Claude Code | `~/.claude/CLAUDE.md` |

Keep project/company-specific instructions in the nearest workspace or repository
`AGENTS.md`/`CLAUDE.md`; the global file should stay personal and reusable.

### Shared Skills

Generic skills live in `config/agents/skills/`. The installer symlinks each skill
folder into:

| Tool | Skill path |
|------|------------|
| OpenCode | `~/.config/opencode/skills/<skill>` |
| Generic agents | `~/.agents/skills/<skill>` |
| Codex | `~/.codex/skills/<skill>` |
| Claude Code | `~/.claude/skills/<skill>` |

The first shared skill is `dotfiles-sync`, which gives agents the safe update
workflow for this repo.

### Workspace Instructions

Workspace-level instructions are installed from tab-separated mapping files. This
keeps public dotfiles generic while allowing private work/personal overlays.

The installer reads these files when present:

| File | Intended use |
|------|--------------|
| `config/agents/workspaces/links.tsv` | Optional public mappings |
| `config/agents/workspaces/*.local.tsv` | Local/private mappings inside this checkout |
| `~/.config/agents/workspaces.tsv` | Private mappings outside the public repo |

Mapping format:

```text
<workspace-path>	<instruction-file>	<targets>
```

Example:

```text
~/work/repos	~/.config/agents/workspaces/work/AGENTS.md	AGENTS.md,CLAUDE.md
```

The `targets` column is optional and defaults to `AGENTS.md,CLAUDE.md`. Keep
sensitive workspace instruction files in a private repo or under `~/.config/agents`.

## Zsh Modules

| File | Purpose |
|------|---------|
| `exports.zsh` | PATH, GOPATH, ANDROID_SDK_ROOT, EDITOR, NIX_BUILD_GROUP_ID |
| `git.zsh` | Git aliases, mkpr, gmc*, gmm*, jira*, opendev/openqa/openst/openprod |
| `adb.zsh` | `adb_reverse_ensure()` - smart adb reverse port mapping |
| `work.zsh` | rp-*, magiclink-login, rp-login, redshift-login |
| `tools.zsh` | jenv (lazy), mise (lazy), direnv, fzf, gh copilot, claude |
| `local.zsh` | Machine-specific: theme, plugins, fpath, tmux exit (gitignored) |
| `secrets.zsh` | API keys: RP_UUID_CREDENTIAL, RP_QA_API_KEY (gitignored) |

## Tmux

Tmux config lives in `config/tmux/tmux.conf`. The installer links it to both
`~/.config/tmux/tmux.conf` and `~/.tmux.conf` for XDG and legacy tmux startup
compatibility.

Plugins are declared for TPM:

| Plugin | Purpose |
|--------|---------|
| `tmux-plugins/tpm` | Plugin manager |
| `tmux-plugins/tmux-resurrect` | Save and restore tmux sessions |
| `tmux-plugins/tmux-continuum` | Automatic session save/restore integration |

Keep cloned plugin repositories and resurrected session state under `~/.tmux/`;
do not commit them to this public repo.

## Features

- **Lazy-loaded tools**: jenv, mise, nvm only initialize on first use (~500ms saved)
- **Smart adb reverse**: Checks existing mappings before adding
- **Tmux**: Portable tmux options with TPM plugin declarations
- **Modular**: Each concern in its own file
- **macOS/Linux portable**: Detects Homebrew/Linuxbrew, Android SDK, gh, jenv, mise, fzf
- **Machine-specific**: `local.zsh` for per-machine customization
- **Secrets**: API keys in separate gitignored file

## Adding a New Machine

1. Clone repo: `git clone git@github.com:rp-arielrodriguez/dotfiles.git ~/dotfiles`
2. Run install: `cd ~/dotfiles && ./scripts/install.sh`
3. Edit secrets: `vim ~/.config/zsh/secrets.zsh`
4. Edit local config: `vim ~/.config/zsh/local.zsh`
5. Install spaceship theme (if using): `git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"`
6. Install plugins:
   ```bash
   git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
   git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
   ```
