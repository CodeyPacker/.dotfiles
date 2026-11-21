#!/bin/sh
# Copies the Herdr app's settings files between this repo and the app's config folder.
# The app rewrites these files in place, so they are copied, not linked.
#   pull (default): repo -> app
#   push:           app -> repo, run after changing a setting, keybind or letter in the app
# Name files after the mode to copy only those, for example: sync-config.sh push hints.json
# The repo files store the home folder as {{HOME}} so they work on every machine.
# Keep the file list in step with sync-config.ps1 and .githooks/post-merge.

set -eu

ALL_FILES="keys.json hints.json settings.json mods/islands-workspace-chrome/settings.json"

MODE=${1:-pull}
[ $# -gt 0 ] && shift
# shellcheck disable=SC2086
[ $# -eq 0 ] && set -- $ALL_FILES

case "$MODE" in
  pull | push) ;;
  *)
    echo "Usage: sync-config.sh [pull|push] [file ...]" >&2
    echo "Files: $ALL_FILES" >&2
    exit 1
    ;;
esac

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
APP_DIR="$HOME/.config/herdr-app"

if [ ! -d "$APP_DIR" ]; then
  echo "Herdr app config folder not found, skipping sync: $APP_DIR"
  exit 0
fi

new_file=$(mktemp)
trap 'rm -f "$new_file"' EXIT

for file in "$@"; do
  case " $ALL_FILES " in
    *" $file "*) ;;
    *)
      echo "Unknown file: $file. Use one of: $ALL_FILES" >&2
      exit 1
      ;;
  esac

  if [ "$MODE" = "pull" ]; then
    source_file="$SCRIPT_DIR/$file"
    target_file="$APP_DIR/$file"
  else
    source_file="$APP_DIR/$file"
    target_file="$SCRIPT_DIR/$file"
  fi

  if [ ! -f "$source_file" ]; then
    echo "Skipping $file, missing: $source_file"
    continue
  fi

  # A mod's settings file has nowhere to go until that mod is installed.
  target_dir=$(dirname -- "$target_file")
  if [ ! -d "$target_dir" ]; then
    echo "Skipping $file, folder missing: $target_dir"
    continue
  fi

  if [ "$MODE" = "pull" ]; then
    sed "s|{{HOME}}|$HOME|g" "$source_file" > "$new_file"
  else
    sed "s|$HOME|{{HOME}}|g" "$source_file" > "$new_file"
  fi

  if [ -f "$target_file" ] && cmp -s "$new_file" "$target_file"; then
    echo "Already matches: $target_file"
    continue
  fi

  if [ "$MODE" = "pull" ] && [ -f "$target_file" ]; then
    cp "$target_file" "$target_file.bak-before-sync"
  fi

  cat "$new_file" > "$target_file"
  echo "${MODE}ed $file: $source_file -> $target_file"
done
