#!/usr/bin/env bash
# Terminal setup: Ghostty + oh-my-bash + Starship (Catppuccin). Tested on Ubuntu.
set -euo pipefail
cd "$(dirname "$0")"
stamp=$(date +%F-%H%M%S)

backup() { [ -e "$1" ] && cp -r "$1" "$1.bak-$stamp" && echo "backed up $1 -> $1.bak-$stamp" || true; }

echo "==> Installing CLI tools (needs sudo)"
sudo apt update
sudo apt install -y git curl fzf zoxide eza bat fd-find fonts-jetbrains-mono

echo "==> Installing oh-my-bash"
if [ ! -d "$HOME/.oh-my-bash" ]; then
  git clone --depth=1 https://github.com/ohmybash/oh-my-bash.git "$HOME/.oh-my-bash"
fi

echo "==> Installing Starship"
mkdir -p "$HOME/.local/bin"
if ! command -v starship >/dev/null && [ ! -x "$HOME/.local/bin/starship" ]; then
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
fi

echo "==> Installing Symbols Nerd Font (icons for VS Code / other terminals)"
mkdir -p "$HOME/.local/share/fonts"
tmp=$(mktemp -d)
curl -fsSL -o "$tmp/f.tar.xz" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.tar.xz
tar -xJf "$tmp/f.tar.xz" -C "$tmp"
cp "$tmp"/SymbolsNerdFont*.ttf "$HOME/.local/share/fonts/"
rm -rf "$tmp"
fc-cache -f >/dev/null

echo "==> Copying configs"
mkdir -p "$HOME/.config/ghostty"
backup "$HOME/.config/ghostty/config"
cp ghostty/config "$HOME/.config/ghostty/config"
backup "$HOME/.config/starship.toml"
cp starship.toml "$HOME/.config/starship.toml"
backup "$HOME/.bashrc"
cp bashrc "$HOME/.bashrc"

echo
echo "Done. Restart Ghostty (or open a new tab)."
echo "Your old ~/.bashrc was saved as ~/.bashrc.bak-$stamp, so copy back anything you need from it (PATH, nvm, etc.)."
