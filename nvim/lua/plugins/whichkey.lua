return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    plugins = { spelling = false },
    spec = {
      { "<leader><tab>", desc = "Toggle Recent File" },
      { "<leader>b", desc = "Toggle Explorer" },
      { "<leader>c", group = "Code" },
      { "<leader>f", group = "Find" },
      { "<leader>m", group = "Marks/Markdown" },
      { "<leader>n", group = "Notifications" },
      { "<leader>s", group = "Splits/Scratch" },
      { "<leader>t", group = "Tabs/Tasks/Toggle" },
      { "<leader>z", desc = "Toggle Zen Mode" },
    },
  },
}
