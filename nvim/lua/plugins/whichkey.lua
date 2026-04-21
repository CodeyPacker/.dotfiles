return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    plugins = { spelling = false },
    spec = {
      { "<leader>f", group = "Find" },
      { "<leader>t", group = "Tabs/Toggle" },
      { "<leader>s", group = "Splits" },
    },
  },
}
