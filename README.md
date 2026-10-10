# Terminal setup

Ghostty + oh-my-bash + Starship, Catppuccin Mocha theme. Built for Ubuntu with bash.

## Install

1. Install Ghostty: https://ghostty.org/docs/install/binary
2. Run:
   ```bash
   ./install.sh
   ```
   It backs up your existing `~/.bashrc`, `~/.config/ghostty/config` and `~/.config/starship.toml` first.
   **It replaces `~/.bashrc`**, so afterwards copy anything you need (PATH, nvm, pyenv…) back from the `.bak-*` file.
3. Restart Ghostty.

## What's included

| File | Goes to |
|---|---|
| `ghostty/config` | `~/.config/ghostty/config` |
| `starship.toml` | `~/.config/starship.toml` |
| `bashrc` | `~/.bashrc` |

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

## VS Code terminal icons

Ghostty has icons built in. For VS Code, set this in settings.json (the font is installed by `install.sh`):
```json
"terminal.integrated.fontFamily": "'JetBrains Mono', 'Symbols Nerd Font Mono', monospace"
```
