---
name: herdr-background
description: Change the Herdr desktop app background image by picking from the pictures in the user's Pictures\herdr folder. Use when the user asks to change, switch, or pick their Herdr background or wallpaper.
---

# Herdr background picker

The helper script `set-background.ps1` sits next to this file. Run it with PowerShell.

1. List the pictures:

   ```powershell
   & "$HOME\.claude\skills\herdr-background\set-background.ps1"
   ```

   It prints one image file name per line from `<Pictures>\herdr`.

2. Let the user pick one.
   - 4 or fewer images: use AskUserQuestion with one option per file name.
   - More than 4: print them as a numbered list and ask the user for a number or name.
   - If the user already named an image in their request, skip the question.

3. Apply the pick:

   ```powershell
   & "$HOME\.claude\skills\herdr-background\set-background.ps1" "<file name>"
   ```

   The script copies the image into `~\.config\herdr-app\backgrounds\` (Herdr only reads images from its own folder) and sets `background.image` in the active layout file (`layouts\<layout>.json`, where the layout name comes from `shared.json`). It keeps the current `fit`, or uses `cover`.

4. Herdr reloads layout files live, so no restart is needed. Report the script's one-line output.
