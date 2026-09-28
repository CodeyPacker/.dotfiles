# Harpoon

Mark files, then reorder or open them from an editable buffer.

| Command | Action |
| --- | --- |
| `harpoon.mark` | Add the active file to the mark list |
| `harpoon.menu` | Toggle the mark list buffer |
| `harpoon.open` | Open the file on the cursor line (bound to `enter` inside the buffer) |

The mark list is a plain text buffer showing workspace-relative paths, with the
directory dimmed and file names aligned in a column. Deleting and moving lines
rewrites the list, so `dd` and `p` reorder marks. Marks are stored per workspace.
