# Neovim Shortcuts

`<leader>` = `Space`

This file is the canonical shortcut reference for this repo. Keep it in sync with the Neovim mappings under `nvim/`.

## Navigation

- `jk` in insert mode: exit insert mode
- `<C-h>`: focus the split to the left
- `<C-j>`: focus the split below
- `<C-k>`: focus the split above
- `<C-l>`: focus the split to the right
- `<leader><Tab>`: toggle between the two most recent files
- `<leader>h`: clear search highlighting

## Files And Search

- `<leader>ff`: find files
- `<leader>fg`: find git files
- `<leader>fs`: grep for a string
- `<leader>fb`: list open buffers
- `<leader>fr`: open recent files
- `<leader>fp`: list projects
- `<leader>fc`: find files in the Neovim config directory

## Explorer, Notes, And Marks

- `<leader>b`: toggle the file explorer
- `<leader>m`: mark the current file in Harpoon
- `<leader>me`: show Harpoon marks
- `<leader>sn`: open a new scratch buffer
- `<leader>sl`: list scratch buffers
- `<leader>nh`: open notification history
- `<leader>z`: toggle zen mode

## Splits And Tabs

- `<leader>sh`: split the current window below
- `<leader>se`: equalize split sizes
- `<leader>sx`: close the current split
- `<leader>To`: open a new tab
- `<leader>Tx`: close the current tab
- `<leader>Tn`: go to the next tab
- `<leader>Tp`: go to the previous tab

## Tasks And Terminal

- `<leader>tr`: run an Overseer task
- `<leader>tR`: restart the most recent Overseer task
- `<leader>tl`: toggle the Overseer task list
- `<Esc>` in Overseer task list: close the floating task list
- `<leader>tt`: toggle the terminal
- `<leader>tg`: toggle Lazygit

## Diagnostics And LSP

- `gl`: show diagnostics for the current line
- `[d`: go to the previous diagnostic
- `]d`: go to the next diagnostic
- `K`: hover documentation
- `gd`: go to definition
- `<leader>ca`: code action
- `<leader>fm`: format the current buffer

## Markdown And AI

- `<leader>xd`: preview the current Markdown file
- `<C-;>` in insert mode: accept Copilot suggestion
- `<C-/>` in insert mode: dismiss Copilot suggestion

## Notes

- `Tab` does not accept Copilot suggestions in this config.
- `OverseerQuickAction` exists as a command but is not mapped to a key.
