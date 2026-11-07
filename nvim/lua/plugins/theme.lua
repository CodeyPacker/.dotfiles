-- Xcode dark syntax colors. UI accents use the PReview palette shared with WezTerm and Starship.
return {
  {
    "arzg/vim-colors-xcode",
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.termguicolors = true
      vim.cmd.colorscheme("xcodedark")
      -- UI groups on top of the theme. Backgrounds stay clear so Herdr's card shows through.
      local overrides = {
        Normal = { fg = "#f4f3f9", bg = "NONE" },
        NormalNC = { fg = "#f4f3f9", bg = "NONE" },
        SignColumn = { fg = "#f4f3f9", bg = "NONE" },
        FoldColumn = { fg = "#f4f3f9", bg = "NONE" },
        LineNr = { fg = "#8c89a0", bg = "NONE" },
        NonText = { fg = "#8c89a0", bg = "NONE" },
        Whitespace = { fg = "#8c89a0", bg = "NONE" },
        EndOfBuffer = { fg = "#8c89a0", bg = "NONE" },
        CursorLineNr = { fg = "#b5a6ff", bg = "NONE", bold = true },
        -- Clear like the pane. A filled cursor line made Herdr draw the line's text white.
        CursorLine = { bg = "NONE" },
        Cursor = { fg = "#14131b", bg = "#9c88ff" },
        Visual = { fg = "#f4f3f9", bg = "#2b2452" },
        WinSeparator = { fg = "#4e3fa3", bg = "NONE" },
        NormalFloat = { fg = "#f4f3f9", bg = "#262433" },
        Pmenu = { fg = "#f4f3f9", bg = "#262433" },
        FloatBorder = { fg = "#4e3fa3", bg = "#262433" },
        FloatTitle = { fg = "#b5a6ff", bg = "#2b2452", bold = true },
        PmenuSel = { fg = "#b5a6ff", bg = "#29234a", bold = true },
        PmenuThumb = { bg = "#4e3fa3" },
        PmenuSbar = { bg = "#14131b" },
        StatusLine = { fg = "#aba8bd", bg = "NONE" },
        StatusLineNC = { fg = "#aba8bd", bg = "NONE" },
        TabLineFill = { fg = "#aba8bd", bg = "NONE" },
        TabLine = { fg = "#aba8bd", bg = "#262433" },
        TabLineSel = { fg = "#b5a6ff", bg = "#2b2452", bold = true },
        Directory = { fg = "#f8c15a" },
        HarpoonFilename = { fg = "#b5a6ff" },
        HarpoonMenuNormal = { fg = "#f4f3f9", bg = "NONE" },
        HarpoonMenuBorder = { fg = "#4e3fa3", bg = "NONE" },
        HarpoonMenuTitle = { fg = "#b5a6ff", bg = "NONE", bold = true },
        SnacksPickerDirectory = { fg = "#f4f3f9" },
        SnacksPickerFile = { fg = "#f4f3f9" },
        WhichKey = { fg = "#b5a6ff" },
        SnacksPickerDir = { fg = "#aba8bd" },
        SnacksPickerMatch = { fg = "#b5a6ff", bold = true },
        SnacksPickerListCursorLine = { fg = "#f4f3f9", bg = "NONE", bold = true },
        SnacksPickerTitle = { fg = "#b5a6ff", bg = "NONE", bold = true },
        SnacksPickerToggle = { fg = "#86afff", bg = "NONE", bold = true },
        SnacksPickerHiddenCursor = { blend = 100, nocombine = true },
        -- Pickers and the explorer sit on the editor background, like harpoon,
        -- so rounded borders have no square corner cells.
        SnacksPicker = { fg = "#f4f3f9", bg = "NONE" },
        SnacksPickerBox = { fg = "#f4f3f9", bg = "NONE" },
        SnacksPickerList = { fg = "#f4f3f9", bg = "NONE" },
        SnacksPickerInput = { fg = "#f4f3f9", bg = "NONE" },
        SnacksPickerBorder = { fg = "#4e3fa3", bg = "NONE" },
        SnacksPickerBoxBorder = { fg = "#4e3fa3", bg = "NONE" },
        SnacksPickerInputBorder = { fg = "#4e3fa3", bg = "NONE" },
        SnacksIndent = { fg = "#262433" },
        SnacksIndentScope = { fg = "#4e3fa3" },
        -- Find and replace float: hairline border, accent only on matches.
        GrugFarFloatBorder = { fg = "#3a3848", bg = "#262433" },
        GrugFarFloatTitle = { fg = "#f4f3f9", bg = "#262433", bold = true },
        GrugFarCursorLine = { bg = "#29234a" },
        GrugFarInputLabel = { fg = "#aba8bd" },
        GrugFarInputPlaceholder = { fg = "#7a778d" },
        GrugFarResultsHeader = { fg = "#2a2837" },
        GrugFarResultsStats = { fg = "#aba8bd" },
        GrugFarResultsActionMessage = { fg = "#aba8bd" },
        GrugFarResultsPath = { fg = "#f4f3f9", bold = true },
        -- The border hairline (#ffffff14) laid over surface-raised.
        GrugFarFileRow = { bg = "#353341" },
        GrugFarFileRowDir = { fg = "#aba8bd", bold = false },
        GrugFarResultsLineNr = { fg = "#7a778d" },
        GrugFarResultsCursorLineNo = { fg = "#b5a6ff" },
        GrugFarResultsLongLineStr = { fg = "#7a778d" },
        GrugFarResultsMatch = { fg = "#b5a6ff", bg = "#2b2452", bold = true },
        GrugFarResultsMatchAdded = { fg = "#45d69a", bg = "#10301f" },
        GrugFarResultsMatchRemoved = { fg = "#ff7b7f", bg = "#3a171b", strikethrough = true },
        GrugFarResultsChangeIndicator = { fg = "#b5a6ff" },
        GrugFarResultsAddIndicator = { fg = "#45d69a" },
        GrugFarResultsRemoveIndicator = { fg = "#ff7b7f" },
        GrugFarCurrentMatch = { fg = "#f4f3f9", bg = "#4e3fa3", bold = true },
        PreviewNormal = { fg = "#b5a6ff", bg = "#2b2452", bold = true },
        PreviewInsert = { fg = "#45d69a", bg = "#10301f", bold = true },
        PreviewVisual = { fg = "#f8c15a", bg = "#3a2a0e", bold = true },
        PreviewReplace = { fg = "#ff7b7f", bg = "#3a171b", bold = true },
        PreviewFile = { fg = "#f4f3f9", bg = "#262433", bold = true },
        PreviewInfo = { fg = "#86afff", bg = "#15264a", bold = true },
        PreviewWarning = { fg = "#f8c15a", bg = "#3a2a0e", bold = true },
        PreviewError = { fg = "#ff7b7f", bg = "#3a171b", bold = true },
        PreviewSuccess = { fg = "#45d69a", bg = "#10301f", bold = true },
        DiagnosticError = { fg = "#ff7b7f" },
        DiagnosticVirtualTextError = { fg = "#ff7b7f", bg = "#3a171b" },
        DiagnosticSignError = { fg = "#ff7b7f", bg = "NONE" },
        DiagnosticWarn = { fg = "#f8c15a" },
        DiagnosticVirtualTextWarn = { fg = "#f8c15a", bg = "#3a2a0e" },
        DiagnosticSignWarn = { fg = "#f8c15a", bg = "NONE" },
        DiagnosticInfo = { fg = "#86afff" },
        DiagnosticVirtualTextInfo = { fg = "#86afff", bg = "#15264a" },
        DiagnosticSignInfo = { fg = "#86afff", bg = "NONE" },
        DiagnosticHint = { fg = "#b5a6ff" },
        DiagnosticVirtualTextHint = { fg = "#b5a6ff", bg = "#2b2452" },
        DiagnosticSignHint = { fg = "#b5a6ff", bg = "NONE" },
      }
      for group, spec in pairs(overrides) do
        vim.api.nvim_set_hl(0, group, spec)
      end
      -- Embedded terminals use the exact same ANSI palette as WezTerm.
      local ansi = {
        "#14131b", "#ff7b7f", "#45d69a", "#f8c15a",
        "#86afff", "#b5a6ff", "#5fd3b0", "#aba8bd",
        "#8c89a0", "#ff9c8f", "#45d69a", "#f8c15a",
        "#8fb0ff", "#c4a7ff", "#6cc4ff", "#f4f3f9",
      }
      for index, color in ipairs(ansi) do
        vim.g["terminal_color_" .. (index - 1)] = color
      end
      require("config.statusline").setup()
    end,
  },
}
