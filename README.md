# Dotfiles

Personal dotfiles for Ariel Rodriguez.

## Install

```bash
git clone git@github.com:rp-arielrodriguez/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/install.sh
```

## Structure

```
~/dotfiles/
├── home/                    # Symlinked to ~
│   ├── .zshrc
│   ├── .zshenv
│   └── .gitconfig
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
└── scripts/
    └── install.sh
```

## After Install

1. Edit `~/.config/zsh/secrets.zsh` with your API keys
2. Edit `~/.config/zsh/local.zsh` for machine-specific settings (theme, plugins)
3. Restart your shell: `exec zsh`

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

## Features

- **Lazy-loaded tools**: jenv, mise, nvm only initialize on first use (~500ms saved)
- **Smart adb reverse**: Checks existing mappings before adding
- **Modular**: Each concern in its own file
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
