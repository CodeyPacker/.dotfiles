return {
  {
    "rose-pine/neovim",
    lazy = false,
    name = "rose-pine",
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        dark_variant = "moon",
        dim_inactive_windows = false,
        extend_background_behind_borders = false,
        styles = {
          italic = false,
          transparency = vim.uv.os_uname().sysname == "Darwin"
            or string.find(vim.uv.os_uname().sysname, "Windows") ~= nil
            or string.find(vim.uv.os_uname().release, "WSL") ~= nil,
        },
      })

      vim.cmd.colorscheme("rose-pine")

      local palette = require("rose-pine.palette")
      local elements = {
        "Normal",
        "NonText",
        "NormalNC",
        "StatusLineNC",
        "VertSplit",
        "WinSeparator",
        "HarpoonWindow",
        "NormalFloat",
        "FloatBorder",
        "Pmenu",
        "PmenuSel",
        "StatusLine",
        "EndOfBuffer",
        "LineNr",
      }

      for _, element in ipairs(elements) do
        vim.api.nvim_set_hl(0, element, { bg = "NONE", ctermbg = "NONE" })
      end

      vim.api.nvim_set_hl(0, "SnacksPickerDir", { fg = palette.subtle })
      vim.api.nvim_set_hl(0, "LineNr", { fg = palette.subtle, bg = "NONE", ctermfg = 240, ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "NonText", { fg = palette.muted, bg = "NONE", ctermfg = 238, ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = palette.muted, bg = "NONE", ctermfg = 238, ctermbg = "NONE" })
    end,
  },
}
