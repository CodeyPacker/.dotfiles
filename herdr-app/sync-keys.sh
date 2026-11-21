#!/bin/sh
# Copies Herdr app keybinds between this repo and the app's config folder.
#   pull (default): repo -> app
#   push:           app -> repo, run after changing a keybind in the app
# The repo file stores the home folder as {{HOME}} so it works on every machine.

set -eu

MODE=${1:-pull}
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_FILE="$SCRIPT_DIR/keys.json"
APP_DIR="$HOME/.config/herdr-app"
APP_FILE="$APP_DIR/keys.json"

if [ ! -d "$APP_DIR" ]; then
  echo "Herdr app config folder not found, skipping keybind sync: $APP_DIR"
  exit 0
fi

new_file=$(mktemp)
trap 'rm -f "$new_file"' EXIT

case "$MODE" in
  pull)
    source_file=$REPO_FILE
    target_file=$APP_FILE
    sed "s|{{HOME}}|$HOME|g" "$source_file" > "$new_file"
    ;;
  push)
    source_file=$APP_FILE
    target_file=$REPO_FILE
    if [ ! -f "$source_file" ]; then
      echo "No keybinds to push. Missing: $source_file" >&2
      exit 1
    fi
    sed "s|$HOME|{{HOME}}|g" "$source_file" > "$new_file"
    ;;
  *)
    echo "Usage: sync-keys.sh [pull|push]" >&2
    exit 1
    ;;
esac

if [ -f "$target_file" ] && cmp -s "$new_file" "$target_file"; then
  echo "Herdr keybinds already match: $target_file"
  exit 0
fi

if [ "$MODE" = "pull" ] && [ -f "$target_file" ]; then
  cp "$target_file" "$target_file.bak-before-sync"
fi

cat "$new_file" > "$target_file"
echo "Herdr keybinds ${MODE}ed: $source_file -> $target_file"
