---
name: herdr-background
description: Change the Herdr desktop app background picture and how much of it shows behind the terminal panes. Opens an interactive picker in Herdr, or sets a named picture directly. Use when the user asks to change, switch, or pick their Herdr background or wallpaper.
---

# Herdr background picker

## The picker (default)

Open it in the running Herdr app:

```sh
herdr-app do mod.open:wallpaper
```

Then tell the user how it works, in a few lines:

- It shows the pictures in their folder (`~/Pictures/herdr` until they choose another with `f` or the Folder… button; the choice is remembered).
- Arrows or hjkl move through the pictures, and each one shows as the background at once.
- Enter goes to the pane opacity: left and right change it by 5%, shift by 1%, again shown at once. 100% is solid panes, lower shows the picture behind the terminals.
- Enter goes to the borders: left and right (or h and l) pick the theme's color, light or dark (faint white or black, for busy pictures), again shown at once.
- Enter keeps it all. Esc puts back what was there before. `ctrl-a w` opens the picker any time.

The picker is the `wallpaper` Herdr mod in `herdr-mod/` next to this file. It changes the layout with `layout.set`, which shows the change at once and saves the layout file.

## Setting a picture directly

When the user names a picture and the look in the request, or Herdr is not running, use the script next to this file instead:

- macOS and Linux: `~/.claude/skills/herdr-background/set-background.sh`
- Windows: `& "$HOME\.claude\skills\herdr-background\set-background.ps1"` in PowerShell

1. With no arguments it prints one picture file name per line from `~/Pictures/herdr` (`<Pictures>\herdr` on Windows). If the folder is missing or empty, tell the user to put pictures there and stop.
2. Run it with the file name and `solid` or `clear`:

   ```sh
   ~/.claude/skills/herdr-background/set-background.sh "<file name>" solid
   ```

   `solid` keeps the terminals in the theme color, so the picture shows only around the panes. `clear` draws them at 85%, so the picture shows faintly behind them. The script copies the picture into `~/.config/herdr-app/backgrounds/` (Herdr only reads pictures from its own folder), sets the active layout's root `background` and `terminal_opacity`, and with `clear` removes each pane's own `background`. It refuses a layout that is a link (a shipped one): tell the user to clone it in Herdr's settings first.
3. Herdr reloads the layout file within a few seconds. Report the script's one-line output.
