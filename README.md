# dotfiles

Config and app setup for my Ubuntu dev machine. No secrets or data. `make help` lists every target.

## Snapshot (old machine)

```bash
make backup   # config -> home/, package lists + repo URLs -> packages/
```

## Rebuild (fresh machine)

```bash
sudo apt install -y make git
cd dotfiles
make install     # everything; or run single targets
```

Log out and back in afterwards for the docker group and GNOME settings.

## Not covered

SSH/AWS/GPG keys, project `.env` files, databases and docker volumes, browser profiles, app logins.

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

