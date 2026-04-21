# Plugin Keybind Cheatsheet

`<leader>` = `Space`

## Process / terminal

- `<leader>tr` -> run an Overseer task
- `<leader>tR` -> restart the most recent Overseer task
- `<leader>tl` -> open/toggle the Overseer task list in a floating window
- `<Esc>` -> close the Overseer task list window
- `<leader>tt` -> toggle Snacks terminal
- `<leader>tg` -> toggle Lazygit via Snacks

Important: there is no manually mapped "stop process/task" keybind in this repo. `OverseerQuickAction` is available as a command, but it is not bound to a key.

## Picker / explorer / notes

- `<leader>ff` -> find files
- `<leader>fg` -> find git files
- `<leader>fs` -> grep
- `<leader>fb` -> buffers
- `<leader>fr` -> recent files
- `<leader>fp` -> projects
- `<leader>fc` -> find config files
- `<leader>b` -> toggle explorer
- `<leader>nh` -> notification history
- `<leader>sn` -> new scratch
- `<leader>sl` -> scratch list

## Harpoon / UI

- `<leader>m` -> mark the current file in Harpoon
- `<leader>e` -> show the Harpoon marked files menu
- `<leader>z` -> toggle zen mode

## LSP / markdown

- `<leader>ca` -> code action
- `gl` -> line diagnostics
- `[d` -> previous diagnostic
- `]d` -> next diagnostic
- `K` -> hover
- `gd` -> definition
- `<leader>md` -> markdown preview with Glow

## Copilot

- `Ctrl-;` -> accept Copilot suggestion
- `Ctrl-/` -> dismiss Copilot suggestion
- `Tab` -> does not accept Copilot suggestions

## Source files

- `nvim/lua/plugins/overseer.lua`
- `nvim/lua/plugins/snacks.lua`
- `nvim/lua/plugins/harpoon.lua`
- `nvim/lua/plugins/glow.lua`
- `nvim/lua/plugins/lsp-config.lua`
