return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    plugins = { spelling = false },
    spec = {
      { "<leader><tab>", desc = "Toggle Recent File" },
      { "<leader>T", group = "Tabs" },
      { "<leader>b", desc = "Toggle Explorer" },
      { "<leader>c", group = "Code" },
      { "<leader>f", group = "Find" },
      { "<leader>fm", desc = "Format Buffer" },
      { "<leader>m", group = "Marks" },
      { "<leader>ma", desc = "Add File" },
      { "<leader>n", group = "Notifications" },
      { "<leader>s", group = "Splits/Scratch" },
      { "<leader>t", group = "Tasks/Toggle" },
      { "<leader>x", group = "Markdown/Extras" },
      { "<leader>z", desc = "Toggle Zen Mode" },
    },
  },
}
