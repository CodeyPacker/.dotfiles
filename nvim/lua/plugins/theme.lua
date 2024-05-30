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
          comments = { "italic" },
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = { "bold" },
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = { "italic" },
        },
        color_overrides = {
          mocha = {
            base = "#1E1E2E",
            mantle = "#1A1826",
            crust = "#161320",
          },
        },
      })

      vim.cmd.colorscheme("catppuccin")

      vim.cmd("highlight Normal guibg=#1E1E2E50")
      vim.cmd("highlight NonText guibg=#1E1E2E50")
      vim.cmd("highlight NormalNC guibg=#1E1E2E50")

     -- Enable transparency for various elements
     vim.cmd("highlight Normal guibg=NONE ctermbg=NONE")
     vim.cmd("highlight NonText guibg=NONE ctermbg=NONE")
     vim.cmd("highlight NormalNC guibg=NONE ctermbg=NONE")
     vim.cmd("highlight NvimTreeNormal guibg=NONE ctermbg=NONE")
     vim.cmd("highlight NvimTreeNormalNC guibg=NONE ctermbg=NONE")
     vim.cmd("highlight StatusLineNC guibg=NONE ctermbg=NONE")
     vim.cmd("highlight NvimTreeVertSplit guibg=NONE ctermbg=NONE guifg=NONE ctermfg=NONE")
     vim.cmd("highlight NvimTreeWinSeparator guibg=NONE ctermbg=NONE guifg=NONE ctermfg=NONE")
     vim.cmd("highlight VertSplit guibg=NONE ctermbg=NONE guifg=NONE ctermfg=NONE")

     -- Make Harpoon pop-up window background transparent
     vim.cmd("highlight HarpoonWindow guibg=NONE ctermbg=NONE")
     vim.cmd("highlight NormalFloat guibg=NONE ctermbg=NONE")
     vim.cmd("highlight FloatBorder guibg=NONE ctermbg=NONE")
     vim.cmd("highlight Pmenu guibg=NONE ctermbg=NONE")
     vim.cmd("highlight PmenuSel guibg=NONE ctermbg=NONE")

     -- Make status lines transparent
     vim.cmd("highlight StatusLine guibg=NONE ctermbg=NONE")
     vim.cmd("highlight StatusLineNC guibg=NONE ctermbg=NONE")
     vim.cmd("highlight NvimTreeStatusLine guibg=NONE ctermbg=NONE")
     vim.cmd("highlight NvimTreeStatusLineNC guibg=NONE ctermbg=NONE")

      -- Make line numbers a darker shade
      vim.cmd("highlight LineNr guifg=#CCCCCC ctermfg=240")
    end,
  },
}

