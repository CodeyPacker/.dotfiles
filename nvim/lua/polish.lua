-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Toggle Neo-tree
vim.keymap.set("n", "<leader>a", ":Neotree toggle<CR>", { noremap = true, silent = true })

-- Navigate to the left buffer
vim.keymap.set("n", "<leader>h", ":bprevious<CR>", { noremap = true, silent = true, desc = "Go to previous buffer" })

-- Navigate to the right buffer
vim.keymap.set("n", "<leader>l", ":bnext<CR>", { noremap = true, silent = true, desc = "Go to next buffer" })

-- Close the current buffer
vim.keymap.set("n", "<leader>w", ":bd<CR>", { noremap = true, silent = true, desc = "Close current buffer" })

-- Close the current terminal buffer
vim.keymap.set(
  "t",
  "<leader>w",
  "<C-\\><C-n>:bd!<CR>",
  { noremap = true, silent = true, desc = "Close terminal buffer" }
)

-- -- Map <leader>fm to format the current file
vim.keymap.set(
  "n",
  "<leader>fm",
  function() vim.lsp.buf.format { async = true } end,
  { noremap = true, silent = true, desc = "Format current file" }
)

-- Insert mode escape with 'jk'
vim.keymap.set("i", "jk", "<Esc>", { noremap = true, silent = true })
