return {
  "ellisonleao/glow.nvim",
  ft = { "markdown" },
  cmd = "Glow",
  opts = {
    style = "dark",
    width = 120,
    border = "rounded",
  },
  keys = {
    { "<leader>md", "<cmd>Glow<CR>", desc = "Preview Markdown" },
  },
}
