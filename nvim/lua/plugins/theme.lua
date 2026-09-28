-- Match VS Code's default "Dark 2026" theme: Dark+ syntax colors with the
-- 2026 editor chrome palette.
return {
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("vscode").setup({
        style = "dark",
        italic_comments = false,
        color_overrides = {
          vscFront = "#bbbebf",
          vscBack = "#121314",
          vscTabCurrent = "#121314",
          vscTabOther = "#191a1b",
          vscTabOutside = "#191a1b",
          vscLeftDark = "#191a1b",
          vscPopupFront = "#bfbfbf",
          vscPopupBack = "#202122",
          vscSplitDark = "#2a2b2c",
          vscCursorDarkDark = "#242526",
          vscCursorLight = "#bbbebf",
          vscSelection = "#276782",
          vscLineNumber = "#858889",
          vscContext = "#343536",
          vscContextCurrent = "#838485",
          vscGitAdded = "#72c892",
          vscGitModified = "#0078d4",
          vscGitDeleted = "#f28772",
        },
        group_overrides = {
          -- No bg so line numbers take the window's bg (e.g. the harpoon float).
          LineNr = { fg = "#858889", bg = "NONE" },
          CursorLineNr = { fg = "#bbbebf", bg = "NONE" },
          StatusLine = { fg = "#8c8c8c", bg = "#191a1b" },
          StatusLineNC = { fg = "#8c8c8c", bg = "#191a1b" },
          WinSeparator = { fg = "#2a2b2c", bg = "NONE" },
          FloatBorder = { fg = "#2a2b2c", bg = "#202122" },
          FloatTitle = { fg = "#bfbfbf", bg = "#202122", bold = true },
          Pmenu = { fg = "#bfbfbf", bg = "#202122" },
          PmenuSel = { fg = "#ffffff", bg = "#297aa0" },
          -- Dark 2026 charts.yellow; Snacks explorer folder icons and names use it.
          Directory = { fg = "#e0b97f" },
          HarpoonFilename = { fg = "#e0b97f" },
        },
      })

      vim.cmd.colorscheme("vscode")
    end,
  },
}
