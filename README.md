# Dotfiles

Personal dotfiles for Ariel Rodriguez.

## Install

```bash
git clone git@github.com:rp-arielrodriguez/dotfiles.git ~/recarga/repos/dotfiles
cd ~/recarga/repos/dotfiles
./scripts/install.sh
```

## Structure

- `config/zsh/` - Modular zsh configuration
- `home/` - Files symlinked to `~`

## Secrets

Copy `secrets.zsh.example` to `secrets.zsh` and add your API keys:

```bash
cp config/zsh/secrets.zsh.example ~/.config/zsh/secrets.zsh
chmod 600 ~/.config/zsh/secrets.zsh
```

## Zsh Modules

| File | Purpose |
|------|---------|
| `exports.zsh` | PATH, GOPATH, ANDROID_SDK_ROOT, EDITOR |
| `git.zsh` | Git aliases, mkpr, gmc*, gmm*, jira* |
| `adb.zsh` | `setup_adb_reverse()` helper |
| `work.zsh` | rp-*, magiclink-login, redshift-login |
| `tools.zsh` | jenv, mise, fzf, gh copilot, claude |
| `secrets.zsh` | API keys (gitignored) |
