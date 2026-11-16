return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("harpoon"):setup()
  end,
  keys = {
    {
      "<leader>m",
      function()
        require("harpoon"):list():add()
      end,
      desc = "Mark File",
    },
    {
      "<leader>e",
      function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = "Show Marked Files",
    },
  },
}
