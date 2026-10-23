# dotfiles

Config and app setup for my dev machine (bash, Ghostty). One `make install` on a fresh
**Ubuntu** (and derivatives like Mint, Pop!_OS, Kubuntu) or **Fedora** (Workstation or KDE) rebuilds the
whole dev environment, on **GNOME** or **KDE Plasma**. No secrets or data are stored here.

The distro is detected from `/etc/os-release` and the desktop from `$XDG_CURRENT_DESKTOP`.
Override either one: `make install DISTRO=fedora DESKTOP=kde`.

## Quick start

On a fresh install:

```bash
sudo apt install -y make git     # Ubuntu
sudo dnf install -y make git     # Fedora
git clone https://github.com/mafzaldev/dotfiles.git ~/dotfiles
cd ~/dotfiles
make install
```

Then log out and back in so the docker group and desktop settings take effect.

Every step is safe to re-run. If one fails, fix it and run just that step, e.g. `make apps`.
Run `make help` to list all steps.

## Updating the snapshot

On the current machine, after changing any config:

```bash
make backup
git diff        # check nothing private slipped in
```

`make backup` copies the config files listed below into `home/` and refreshes the VS Code extension
list and the settings of whichever desktop is running: `packages/dconf-*.ini` on GNOME,
`packages/kde.ini` on KDE.

## What `make install` does

Steps run in this order (`mongodb` runs last). These differ per distro (`distros/ubuntu.mk`, `distros/fedora.mk`):

| Step | Ubuntu | Fedora |
|---|---|---|
| `base` | `apt upgrade`, curl, gnupg, jq, rsync, unzip | `dnf upgrade`, same tools + dnf5 plugins |
| `repos` | Docker, ngrok, pgAdmin 4, MongoDB 8.0 | Docker, VS Code, pgAdmin 4, MongoDB 8.0 (RHEL 9 repo), COPR for Ghostty, lazygit, Starship |
| `packages` | `packages/ubuntu.txt` + Docker, ngrok, pgAdmin 4 | `packages/fedora.txt` + Docker, VS Code, Ghostty, lazygit, Starship, pgAdmin 4, ngrok |
| `apps` | .debs: Chrome, VS Code, Compass, RedisInsight, Free Download Manager | .rpms: Chrome, Compass, RedisInsight |
| `store-apps` | Snap: Slack, Spotify | Flatpak: Slack, Spotify, Free Download Manager |
| `mongodb` | `mongodb-org` 8.0 (server, mongosh, tools) | `mongodb-org` 8.0 from MongoDB's RHEL 9 repo + MongoDB's SELinux policy |

The rest is the same on both:

| Step | What it does |
|---|---|
| `shell` | oh-my-bash |
| `node` | nvm, Node.js 26.12.1 (default), pnpm, and the pnpm globals in `packages/pnpm-global.txt` |
| `python` | uv and Python 3.12 |
| `go` | Latest Go into `~/.local/go` |
| `cli` | Claude Code |
| `vscode` | VS Code extensions from `packages/vscode-extensions.txt` |
| `dotfiles` | Copies `home/` into `~`. Any file it overwrites is kept as `<name>.pre-dotfiles` |
| `desktop` | **GNOME:** installs Tweaks and the Extensions app, loads `packages/dconf-*.ini`. **KDE:** applies `packages/kde.ini` (see below) |
| `services` | Adds you to the `docker` group, starts Docker and Postgres at boot (initialises Postgres first on Fedora). Redis/Valkey, nginx and MongoDB are installed but not started at boot |

Versions can be overridden per run, e.g. `make node NODE_DEFAULT=24` or `make python PYTHON_VERSIONS="3.12 3.13"`.
To preview another distro's commands: `make -n install DISTRO=fedora`.

### System packages

Same tools on both distros, under each distro's package names: `packages/ubuntu.txt` and `packages/fedora.txt`.

7zip, bat, btop, compilers (build-essential / gcc, gcc-c++, make), curl, drawing, eza, fastfetch, fd, ffmpeg,
flatpak, JetBrains Mono and Noto Color Emoji fonts, fzf, ghostty, git, gnupg, jq,
lazygit, ncdu, net-tools, nginx, podman, PostgreSQL, Python dev headers and pip, Redis (Valkey on Fedora), rsync,
starship, testdisk, unrar, unzip, vlc, wl-clipboard, zip, zoxide

Fedora differences: `ffmpeg-free` instead of full ffmpeg (use RPM Fusion for the full build), Valkey instead of
Redis (drop-in compatible), and no Free Download Manager .rpm, so it comes from Flathub.

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

## Desktop settings

**GNOME** (`packages/dconf-*.ini`): desktop and interface (theme, fonts, cursor, touchpad, mouse), shell
(dock favourites, enabled extensions), mutter (window behaviour) and custom keyboard shortcuts.

**KDE Plasma** (`packages/kde.ini`, applied with `kwriteconfig` by `scripts/kde-settings.sh`), mirroring the
GNOME setup:

| Setting | Value |
|---|---|
| Colour scheme | Breeze Dark |
| Cursor | Bibata Modern Classic, size 20 |
| Fonts | Inter 11 (UI, menus, titles), JetBrains Mono 11 (fixed width) |
| Screen locking | Never auto-locks |
| Power | Screen never dims or turns off when idle (AC and battery) |

Not carried over to KDE: the dock and GNOME extensions, the Yaru theme and Ubuntu wallpaper, and touchpad/mouse
speed (KDE stores those per device). For tiling, use KWin's built-in tiling.

To change a KDE setting, edit `packages/kde.ini`, or change it in System Settings and run `make backup` on the
KDE machine to pull the new values into the file.

## Layout

```
Makefile                 shared install steps, distro detection (make help)
distros/ubuntu.mk        Ubuntu-specific steps (apt, .debs, snaps)
distros/fedora.mk        Fedora-specific steps (dnf, .rpms, COPR, Flatpak)
desktops/gnome.mk        GNOME packages and settings
desktops/kde.mk          KDE Plasma settings
scripts/kde-settings.sh  applies packages/kde.ini, or refreshes it from the running KDE session
scripts/backup.sh        refreshes home/ and packages/ from the current machine
scripts/update-vscode.sh installs or updates VS Code from the official .deb (Ubuntu)
packages/                ubuntu.txt, fedora.txt, pnpm globals, VS Code extensions, GNOME and KDE settings
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

