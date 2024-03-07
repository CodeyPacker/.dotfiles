return {
  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        term_colors = true,
        styles = {
          comments = {},
          conditionals = {},
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
        },
        color_overrides = {
          mocha = {
            base = "#0F0F0F",
            mantle = "#0F0F0F",
            crust = "#0F0F0F",
          },
        },
      })

      vim.cmd.colorscheme("catppuccin")
      vim.cmd.colorscheme("catppuccin")

      -- General transparency
      vim.cmd("highlight Normal guibg=#00000050")
      vim.cmd("highlight NonText guibg=#00000050")
      vim.cmd("highlight NormalNC guibg=#00000050")
      -- File tree transparency
      vim.cmd("highlight NvimTreeNormal guibg=#00000099")
      vim.cmd("highlight NvimTreeNormalNC guibg=#00000099")
      -- Additional elements
      vim.cmd("highlight StatusLineNC guibg=#00000050")
      vim.cmd("highlight VertSplit guibg=NONE")
      vim.cmd("highlight LineNr guifg=#E0E0E0")
      vim.cmd("highlight CursorLineNr guifg=#E0E0E0")
    end,
  },
}
