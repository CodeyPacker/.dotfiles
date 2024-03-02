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
      vim.cmd("highlight Normal guibg=NONE ctermbg=NONE")
      vim.cmd("highlight NonText guibg=NONE ctermbg=NONE")
      vim.cmd("highlight NormalNC guibg=NONE ctermbg=NONE")

      -- File tree transparency
      vim.cmd("highlight NvimTreeNormal guibg=NONE ctermbg=NONE")
      vim.cmd("highlight NvimTreeNormalNC guibg=NONE ctermbg=NONE")
      -- Additional elements
      vim.cmd("highlight StatusLineNC guibg=NONE ctermbg=NONE")
      vim.cmd("highlight VertSplit guibg=NONE ctermbg=NONE")
    end,
  },
}
