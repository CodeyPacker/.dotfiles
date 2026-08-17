local map = vim.keymap.set
local lsp = require("config.lsp")

map("i", "jk", "<Esc>", { noremap = true, silent = true, desc = "Exit Insert Mode" })
map("n", "<leader>h", ":nohlsearch<CR>", { silent = true, desc = "Clear Search Highlight" })

map("n", "<C-k>", ":wincmd k<CR>", { silent = true, desc = "Focus Upper Split" })
map("n", "<C-j>", ":wincmd j<CR>", { silent = true, desc = "Focus Lower Split" })
map("n", "<C-h>", ":wincmd h<CR>", { silent = true, desc = "Focus Left Split" })
map("n", "<C-l>", ":wincmd l<CR>", { silent = true, desc = "Focus Right Split" })

map("n", "<leader>sh", "<C-w>s", { desc = "Split Below" })
map("n", "<leader>se", "<C-w>=", { desc = "Equalize Splits" })
map("n", "<leader>sx", ":close<CR>", { silent = true, desc = "Close Split" })

map("n", "<leader>To", ":tabnew<CR>", { silent = true, desc = "Open Tab" })
map("n", "<leader>Tx", ":tabclose<CR>", { silent = true, desc = "Close Tab" })
map("n", "<leader>Tn", ":tabn<CR>", { silent = true, desc = "Next Tab" })
map("n", "<leader>Tp", ":tabp<CR>", { silent = true, desc = "Previous Tab" })

map("n", "<leader><Tab>", "<C-^>", { desc = "Toggle Recent File" })
map("n", "<leader>fm", lsp.format_buffer, { desc = "Format Buffer" })
