#!/bin/sh
# Lists or sets the Herdr desktop app background image. The macOS and Linux twin of set-background.ps1.
#   set-background.sh                        prints the image file names in ~/Pictures/herdr
#   set-background.sh <name> solid|clear     copies that image into Herdr's backgrounds folder and
#                                            points the active layout at it
# solid: the terminals are drawn in the theme color, so the image shows only around the panes.
# clear: the terminals are drawn at 85% so the image shows faintly behind them. The panes' own
#        background colors are removed, or they would hide it.
# Either way the terminal color comes from the theme, so it follows light and dark mode.

set -eu

SOURCE="$HOME/Pictures/herdr"
APP_HOME="$HOME/.config/herdr-app"

[ -d "$SOURCE" ] || { echo "Picture folder not found: $SOURCE" >&2; exit 1; }

is_image() {
  case "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')" in
    *.png | *.jpg | *.jpeg | *.gif | *.bmp | *.webp) return 0 ;;
    *) return 1 ;;
  esac
}

if [ $# -eq 0 ]; then
  for f in "$SOURCE"/*; do
    [ -f "$f" ] && is_image "$f" && basename "$f"
  done
  exit 0
fi

name=$1
panes=${2:-}
case "$panes" in
  solid) opacity=1 ;;
  clear) opacity=0.61 ;; # Herdr draws terminals twice at this: they look 85% solid
  *) echo "Usage: set-background.sh <name> solid|clear" >&2; exit 1 ;;
esac

image="$SOURCE/$name"
{ [ -f "$image" ] && is_image "$image"; } || { echo "No image named '$name' in $SOURCE" >&2; exit 1; }

# The active layout name is stored in shared.json as "layout".
layout_name=$(jq -r '.layout // "main"' "$APP_HOME/shared.json")
layout="$APP_HOME/layouts/$layout_name.json"
[ -f "$layout" ] || { echo "Layout file not found: $layout" >&2; exit 1; }
# A shipped layout is a link into the app or a mods repo. Change a copy of it instead.
[ -L "$layout" ] && { echo "$layout_name is a linked layout. Clone it in Herdr's settings first, then run this again." >&2; exit 1; }

# Herdr only reads background images from inside its home folder.
mkdir -p "$APP_HOME/backgrounds"
cp "$image" "$APP_HOME/backgrounds/$name"

# jq keeps the key order. The fit stays as it was, or is cover.
new=$(mktemp)
jq --arg image "backgrounds/$name" --argjson opacity "$opacity" --arg panes "$panes" '
  .background = { image: $image, fit: (if (.background | type) == "object" then .background.fit // "cover" else "cover" end) }
  | .terminal_opacity = $opacity
  | if $panes == "clear" then walk(if type == "object" and (.pane | type) == "object" then .pane |= del(.background) else . end) else . end
' "$layout" > "$new"
# Writing through cat keeps the file's permissions.
cat "$new" > "$layout"
rm -f "$new"

echo "Set $layout_name background to backgrounds/$name with $panes panes"
