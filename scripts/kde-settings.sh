#!/usr/bin/env bash
# apply: write packages/kde.ini into the KDE config files.
# dump:  refresh the values in packages/kde.ini from the current KDE session.
set -euo pipefail

INI="$(cd "$(dirname "$0")/.." && pwd)/packages/kde.ini"
KWRITE=$(command -v kwriteconfig6 || command -v kwriteconfig5)
KREAD=$(command -v kreadconfig6 || command -v kreadconfig5)

# "[kcminputrc:Mouse]" -> file=kcminputrc, groups=(--group Mouse)
parse_section() {
  IFS=: read -ra parts <<< "${1:1:-1}"
  file=${parts[0]}
  groups=()
  for g in "${parts[@]:1}"; do groups+=(--group "$g"); done
}

apply() {
  local file="" groups=() line
  while IFS= read -r line; do
    case "$line" in
      ''|'#'*) ;;
      '['*) parse_section "$line" ;;
      *) "$KWRITE" --file "$file" "${groups[@]}" --key "${line%%=*}" "${line#*=}" ;;
    esac
  done < "$INI"

  local scheme cursor size
  scheme=$("$KREAD" --file kdeglobals --group General --key ColorScheme)
  cursor=$("$KREAD" --file kcminputrc --group Mouse --key cursorTheme)
  size=$("$KREAD" --file kcminputrc --group Mouse --key cursorSize)
  # Both tools exit non-zero when the value is already active.
  command -v plasma-apply-colorscheme >/dev/null && plasma-apply-colorscheme "$scheme" || true
  command -v plasma-apply-cursortheme >/dev/null && plasma-apply-cursortheme --size "$size" "$cursor" || true
}

dump() {
  local file="" groups=() line key value out
  out=$(mktemp)
  while IFS= read -r line; do
    case "$line" in
      ''|'#'*) echo "$line" ;;
      '['*) parse_section "$line"; echo "$line" ;;
      *)
        key=${line%%=*}
        value=$("$KREAD" --file "$file" "${groups[@]}" --key "$key")
        echo "$key=${value:-${line#*=}}"
        ;;
    esac
  done < "$INI" > "$out"
  mv "$out" "$INI"
}

case "${1:-}" in
  apply) apply ;;
  dump) dump ;;
  *) echo "usage: $0 apply|dump" >&2; exit 1 ;;
esac
