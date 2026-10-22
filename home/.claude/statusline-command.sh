#!/bin/sh
# Claude Code statusLine. POSIX sh (no bashisms: no arrays, no $'...', no [[ ]]).
# Layout: <dir bold-blue>  <branch magenta>  ctx ▰▰▱▱▱▱▱▱ N%  5h ▰▱▱▱▱ N%  7d ▱▱▱▱▱ N%
# Filled cells colored green(<50%) / yellow(50-79%) / red(>=80%); empty cells dim.
# Any field absent/null in the statusLine JSON is silently omitted (no "null", no errors).

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir')
base=$(basename "$cwd")

BOLD_BLUE=$(printf '\033[1;34m')
MAGENTA=$(printf '\033[0;35m')
DIM=$(printf '\033[2m')
GREEN=$(printf '\033[0;32m')
YELLOW=$(printf '\033[0;33m')
RED=$(printf '\033[0;31m')
RESET=$(printf '\033[0m')
FULL=$(printf '\342\226\260')   # U+25B0 ▰
EMPTY=$(printf '\342\226\261')  # U+25B1 ▱

get_color() {
  if [ "$1" -ge 80 ] 2>/dev/null; then printf '%s' "$RED"
  elif [ "$1" -ge 50 ] 2>/dev/null; then printf '%s' "$YELLOW"
  else printf '%s' "$GREEN"
  fi
}

# bar <pct> <width>: colored filled cells + dim empty cells; any usage > 0 shows at least one cell
bar() {
  pct=$1; width=$2
  filled=$(( (pct * width + 99) / 100 ))
  [ "$filled" -gt "$width" ] && filled=$width
  c=$(get_color "$pct")
  s="$c"; i=0
  while [ "$i" -lt "$filled" ]; do s="$s$FULL"; i=$((i + 1)); done
  s="$s$RESET$DIM"
  while [ "$i" -lt "$width" ]; do s="$s$EMPTY"; i=$((i + 1)); done
  printf '%s%s' "$s" "$RESET"
}

# meter <label> <jq path> <width>
meter() {
  v=$(printf '%s' "$input" | jq -r "$2 // empty")
  [ -z "$v" ] && return
  n=$(printf '%.0f' "$v")
  printf '%s%s%s %s %s%s%%%s' "$DIM" "$1" "$RESET" "$(bar "$n" "$3")" "$(get_color "$n")" "$n" "$RESET"
}

seg_dir=$(printf '%s%s%s' "$BOLD_BLUE" "$base" "$RESET")

branch=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  [ -z "$branch" ] && branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
fi
seg_branch=""
[ -n "$branch" ] && seg_branch=$(printf '%s%s%s' "$MAGENTA" "$branch" "$RESET")

seg_ctx=$(meter ctx '.context_window.used_percentage' 8)
seg_five=$(meter 5h '.rate_limits.five_hour.used_percentage' 5)
seg_week=$(meter 7d '.rate_limits.seven_day.used_percentage' 5)

out=""
for seg in "$seg_dir" "$seg_branch" "$seg_ctx" "$seg_five" "$seg_week"; do
  [ -z "$seg" ] && continue
  if [ -z "$out" ]; then out="$seg"; else out="$out  $seg"; fi
done

printf '%s' "$out"
