return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    plugins = { spelling = false },
    defaults = {},
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.register({
      ["<leader>f"] = { name = "Find" },
      ["<leader>t"] = { name = "Tabs/Toggle" },
      ["<leader>s"] = { name = "Splits" },
    })
  end,
}
