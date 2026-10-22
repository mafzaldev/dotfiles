# dotfiles

Config and app setup for my Ubuntu dev machine (GNOME, bash, Ghostty). One `make install` on a fresh
Ubuntu rebuilds the whole dev environment. No secrets or data are stored here.

## Quick start

On a fresh Ubuntu install:

```bash
sudo apt install -y make git
git clone https://github.com/mafzaldev/dotfiles.git ~/dotfiles
cd ~/dotfiles
make install
```

Then log out and back in so the docker group and GNOME settings take effect.

Every step is safe to re-run. If one fails, fix it and run just that step, e.g. `make apps`.
Run `make help` to list all steps.

## Updating the snapshot

On the current machine, after changing any config:

```bash
make backup
git diff        # check nothing private slipped in
```

`make backup` copies the config files listed below into `home/` and refreshes the VS Code extension
list and GNOME settings in `packages/`.

## What `make install` does

Steps run in this order:

| Step | What it does |
|---|---|
| `base` | `apt update && apt upgrade`, installs curl, gnupg, jq, rsync, unzip |
| `repos` | Adds apt repos for Docker, ngrok, pgAdmin 4 and MongoDB 8.0 |
| `packages` | Installs everything in `packages/apt.txt`, plus Docker, ngrok, pgAdmin 4 and MongoDB |
| `apps` | Downloads and installs Google Chrome, VS Code, MongoDB Compass, LocalSend, RedisInsight and Free Download Manager |
| `snaps` | Slack, Spotify |
| `shell` | oh-my-bash |
| `node` | nvm, Node.js 26.12.1 (default), pnpm, and the pnpm globals in `packages/pnpm-global.txt` |
| `python` | uv and Python 3.12 |
| `go` | Latest Go into `~/.local/go` |
| `cli` | Claude Code |
| `vscode` | VS Code extensions from `packages/vscode-extensions.txt` |
| `dotfiles` | Copies `home/` into `~`. Any file it overwrites is kept as `<name>.pre-dotfiles` |
| `gnome` | Loads the GNOME settings from `packages/dconf-*.ini` |
| `services` | Adds you to the `docker` group, starts Docker and Postgres at boot. Redis, nginx and MongoDB are installed but not started at boot |

Versions can be overridden per run, e.g. `make node NODE_DEFAULT=24` or `make python PYTHON_VERSIONS="3.12 3.13"`.

### apt packages

7zip, bat, btop, build-essential, ca-certificates, curl, dbus-x11, drawing, eza, fastfetch, fd-find, ffmpeg,
flatpak, fonts-jetbrains-mono, fonts-noto-color-emoji, fzf, ghostty, git, gnome-shell-extensions, gnome-tweaks,
gnupg, jq, lazygit, libfuse2t64, libnotify-bin, ncdu, net-tools, nginx, pkg-config, podman, postgresql,
python3-dev, python3-pip, python3-venv, redis, rsync, starship, testdisk, unrar, unzip, vlc, wl-clipboard, zip,
zoxide

### VS Code extensions

One Dark theme, Astro, Tailwind CSS, Ruff, ES7 React snippets, GitLens, Prettier, Auto Rename Tag, Git Graph,
Python, Python Debugger, Pylance, Jupyter (+ keymap, renderers, cell tags, slideshow), Color Highlight, Prisma,
Live Server, vscode-icons.

## Config in `home/`

| Path | What |
|---|---|
| `.bashrc`, `.profile` | oh-my-bash (`font` theme), completions, plugins (git, fzf, zoxide, starship, sudo…), PATH for pnpm/nvm/go, git aliases, eza/bat/fd aliases, Catppuccin fzf colours |
| `.oh-my-bash/custom/` | Custom completions |
| `.config/starship.toml` | Starship prompt (plus an alternative Tokyo Night theme) |
| `.config/ghostty/config` | Ghostty: Catppuccin Mocha/Latte, JetBrains Mono, splits, tabs, dropdown terminal |
| `.config/btop/` | btop settings |
| `.config/lazygit/` | lazygit settings |
| `.config/git/ignore` | Global gitignore |
| `.config/Code/User/` | VS Code `settings.json` and snippets (Atom One Dark, JetBrains Mono, vscode-icons) |
| `.claude/` | Claude Code: global `CLAUDE.md`, `settings.json`, status line script, custom commands (`/analyze`, `/commit`, `/explain`), installed plugin list |
| `.local/share/fonts/` | Symbols Nerd Font (icons), Inter |
| `.icons/Bibata-Modern-Classic/` | Mouse cursor |

GNOME settings in `packages/`: desktop and interface (theme, fonts, cursor, touchpad, mouse), shell
(dock favourites, enabled extensions), mutter (window behaviour) and custom keyboard shortcuts.

## Layout

```
Makefile                 install steps (make help)
scripts/backup.sh        refreshes home/ and packages/ from the current machine
scripts/update-vscode.sh installs or updates VS Code from the official .deb
packages/                apt list, pnpm globals, VS Code extensions, GNOME settings
home/                    files copied into ~ by `make dotfiles`
```

## Not included

Set these up by hand on a new machine:

- **Git identity:** `git config --global user.name "…"` and `user.email`
- **Keys and secrets:** SSH, AWS, GPG keys, project `.env` files
- **Data:** databases, docker volumes, repos in `~/workspace`
- **Logins:** browsers (use sync), Slack, Spotify, VS Code Settings Sync, Claude Code, Stripe CLI

## Cheat sheet

**Shell**
| Key / command | Does |
|---|---|
| `ctrl+r` | fuzzy search history |
| `ctrl+t` | fuzzy-find a file, paste its path |
| `alt+c` | fuzzy cd into a directory |
| `z <name>` | jump to a directory you've visited |
| `Esc Esc` | put `sudo` in front of the current command |
| `ll` / `la` / `lt` | list files with icons + git status / incl. hidden / tree |

**Ghostty**
| Key | Does |
|---|---|
| ``ctrl+` `` | dropdown terminal from any app (GNOME may ask permission once) |
| `ctrl+shift+d` / `ctrl+shift+s` | split right / down |
| `alt+arrows` | move between splits |
| `ctrl+shift+z` | zoom current split |
| `ctrl+shift+e` | equalize splits |
| `ctrl+shift+↑/↓` | jump between previous prompts |
| `ctrl+shift+h` | open scrollback in editor |
| `ctrl+shift+p` | command palette |
| `alt+1..5` | go to tab |
| `ctrl+shift+,` | reload config |

