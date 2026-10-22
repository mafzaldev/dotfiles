#!/usr/bin/env bash
# Download the latest stable VS Code .deb and install it if newer than the installed version.
set -euo pipefail

case "$(dpkg --print-architecture)" in
  amd64) arch="x64" ;;
  arm64) arch="arm64" ;;
  armhf) arch="armhf" ;;
  *) echo "Unsupported architecture: $(dpkg --print-architecture)" >&2; exit 1 ;;
esac

latest=$(curl -fsSL https://update.code.visualstudio.com/api/releases/stable | grep -oP '"\K[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
installed=$(dpkg-query -W -f='${Version}' code 2>/dev/null | cut -d- -f1 || true)

echo "Installed: ${installed:-none}"
echo "Latest:    ${latest}"

if [[ "${1:-}" != "--force" && "$installed" == "$latest" ]]; then
  echo "VS Code is already up to date."
  exit 0
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

deb="$tmpdir/code_${latest}_${arch}.deb"
echo "Downloading VS Code ${latest} (${arch})..."
curl -fL --progress-bar -o "$deb" "https://update.code.visualstudio.com/latest/linux-deb-${arch}/stable"

echo "Installing..."
sudo apt-get install -y "$deb"

echo "VS Code updated to $(dpkg-query -W -f='${Version}' code)."
