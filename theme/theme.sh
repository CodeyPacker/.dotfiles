#!/bin/sh
# Switches light and dark mode on this computer only.
#   theme              prints the mode
#   theme light|dark   sets it
#   theme toggle       switches it
#   theme apply        sets every tool to the saved mode again
# The mode is saved in ~/.config/theme-mode. That file is not in the repo, so each computer keeps its own.
# Follows the mode: the Herdr app ("appearance" in its settings.json) and Claude Code ("theme").
# Keep in step with theme.ps1.
#
# sync-config.sh also uses two helpers, so the repo's Herdr settings never hold a mode:
#   theme.sh herdr-set <file>     writes the saved mode into that Herdr settings file
#   theme.sh herdr-strip <file>   removes the mode from it

set -eu

MODE_FILE="$HOME/.config/theme-mode"
HERDR_SETTINGS="$HOME/.config/herdr-app/settings.json"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"

saved_mode() {
  mode=$(cat "$MODE_FILE" 2>/dev/null || true)
  # No file yet, or something unexpected in it: dark, as before this script.
  if [ "$mode" = "light" ]; then echo light; else echo dark; fi
}

# Herdr writes settings.json with one key per line. These edit that text instead of
# reformatting the JSON, so the rest of the file stays exactly as Herdr wrote it.
strip_appearance() {
  perl -0pe 's/,\s*"appearance"\s*:\s*"[a-z]*"//; s/"appearance"\s*:\s*"[a-z]*"\s*,?\s*//'
}

# Prints the file with "appearance" set to $1, as its last key.
with_appearance() {
  strip_appearance < "$2" | THEME_MODE="$1" perl -0pe '
    s/(\S)\s*\}\s*\z/ ($1 eq "{" ? "{" : "$1,") . "\n  \"appearance\": \"$ENV{THEME_MODE}\"\n}\n" /e'
}

# Rewrites a file only when its text changes. Writing through `cat >` keeps a symlink a symlink.
replace_file() {
  file=$1
  new=$(mktemp)
  cat > "$new"
  if cmp -s "$new" "$file"; then rm -f "$new"; return 0; fi
  cat "$new" > "$file"
  rm -f "$new"
}

apply() {
  mode=$1
  # Herdr applies a settings.json change at once.
  if [ -f "$HERDR_SETTINGS" ]; then
    with_appearance "$mode" "$HERDR_SETTINGS" | replace_file "$HERDR_SETTINGS"
  fi
  # Claude Code draws its own colors: its dark theme is hard to read on a light terminal.
  # Only an existing "theme" line is changed. Sessions that are already open keep their theme.
  if [ -f "$CLAUDE_SETTINGS" ]; then
    THEME_MODE="$mode" perl -0pe 's/("theme"\s*:\s*)"(light|dark)"/$1"$ENV{THEME_MODE}"/' "$CLAUDE_SETTINGS" | replace_file "$CLAUDE_SETTINGS"
  fi
}

save() {
  mkdir -p "$(dirname "$MODE_FILE")"
  printf '%s\n' "$1" > "$MODE_FILE"
  apply "$1"
  echo "$1"
}

case "${1:-}" in
  "") saved_mode ;;
  light | dark) save "$1" ;;
  toggle) if [ "$(saved_mode)" = "dark" ]; then save light; else save dark; fi ;;
  apply) apply "$(saved_mode)" ;;
  herdr-set) with_appearance "$(saved_mode)" "$2" | replace_file "$2" ;;
  herdr-strip) strip_appearance < "$2" | replace_file "$2" ;;
  *)
    echo "Usage: theme [light|dark|toggle|apply]" >&2
    exit 1
    ;;
esac
