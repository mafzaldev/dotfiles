#!/usr/bin/env bash
# Snapshot config and package lists into the dotfiles repo. No secrets or data.
set -euo pipefail

DOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$DOT/home" "$DOT/packages"

# Config files/dirs (relative to $HOME). Never add keys, tokens or .env files here.
CONFIGS=(
  .bashrc .profile
  .config/git/ignore
  .config/starship.toml .config/starship.tokyo-night.toml
  .config/ghostty/config
  .config/btop/btop.conf .config/btop/themes
  .config/lazygit/config.yml
  .config/Code/User/settings.json .config/Code/User/keybindings.json .config/Code/User/snippets
  .claude/CLAUDE.md .claude/settings.json .claude/statusline-command.sh
  .claude/commands .claude/hooks
  .claude/plugins/installed_plugins.json .claude/plugins/known_marketplaces.json
  .oh-my-bash/custom
  .local/share/fonts
  .icons
)

echo "==> Copying config"
cd "$HOME"
for p in "${CONFIGS[@]}"; do
  [[ -e "$p" ]] && rsync -a --relative --delete "$p" "$DOT/home/" || echo "   skip (missing): $p"
done

echo "==> Package lists"
command -v code >/dev/null && code --list-extensions > "$DOT/packages/vscode-extensions.txt"

echo "==> GNOME settings"
for path in desktop shell mutter settings-daemon/plugins/media-keys; do
  dconf dump "/org/gnome/$path/" > "$DOT/packages/dconf-${path//\//.}.ini"
done

echo "Done. Review with: git -C $DOT status"
