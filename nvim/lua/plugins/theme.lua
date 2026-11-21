-- Syntax colors match Tourist's code view on Herdr's slate-dark theme (see `syntax` below).
-- xcodedark (xcodelight in light mode) is only the base. UI accents use the PReview palette
-- shared with Starship. The mode comes from ~/.config/theme-mode, set by `theme` (theme/theme.sh):
-- open Neovims switch as soon as it changes.

local MODE_FILE = vim.fn.expand("~/.config/theme-mode")

-- One color per role, for each mode. Dark values are PReview's dark tokens, light values the
-- same tokens from its light theme.
local palettes = {
  dark = {
    base = "xcodedark",
    text = "#c5c8d0", -- slate-dark's text
    dim = "#8c89a0", -- line numbers, whitespace
    faint = "#7a778d", -- ink-tertiary
    muted = "#aba8bd", -- ink-secondary
    accent = "#b5a6ff", -- accent-text
    focus = "#9c88ff", -- focus-ring
    cursor_text = "#14131b",
    accent_soft = "#2b2452",
    selected = "#29234a",
    border = "#4e3fa3", -- accent-border
    float = "#262433", -- surface-raised
    sunken = "#14131b",
    hover = "#2a2837",
    hairline = "#3a3848", -- the border hairline over surface-raised
    file_row = "#353341",
    indent = "#262433",
    success = "#45d69a",
    success_soft = "#10301f",
    danger = "#ff7b7f",
    danger_soft = "#3a171b",
    warning = "#f8c15a",
    warning_soft = "#3a2a0e",
    info = "#86afff",
    info_soft = "#15264a",
    -- Tourist's mapping (herdr-mods/tourist/mods/tourist/code.js) with slate-dark's values.
    keyword = "#c4a7ff",
    string = "#45d69a",
    comment = "#6f7684",
    func = "#86afff",
    type = "#f8c15a",
    number = "#ff7b7f",
    constant = "#5fd3b0",
    -- Embedded terminals: ANSI 0-15.
    ansi = {
      "#14131b", "#ff7b7f", "#45d69a", "#f8c15a",
      "#86afff", "#b5a6ff", "#5fd3b0", "#aba8bd",
      "#8c89a0", "#ff9c8f", "#45d69a", "#f8c15a",
      "#8fb0ff", "#c4a7ff", "#6cc4ff", "#f4f3f9",
    },
  },
  light = {
    base = "xcodelight",
    text = "#16141f", -- ink
    dim = "#86839a", -- ink-tertiary
    faint = "#86839a",
    muted = "#5c5970", -- ink-secondary
    accent = "#5235d6", -- accent-text
    focus = "#6b4ef6", -- focus-ring
    cursor_text = "#ffffff",
    accent_soft = "#eeeaff",
    selected = "#f0ecff",
    border = "#c6b9fd", -- accent-border
    float = "#f5f4f9", -- surface-sunken: white floats would not stand out
    sunken = "#efedf6",
    hover = "#efedf6",
    hairline = "#dcd9e6",
    file_row = "#e9e7f0",
    indent = "#e6e4ee",
    success = "#0a7a51",
    success_soft = "#e2f6ec",
    danger = "#c2252c",
    danger_soft = "#fdebec",
    warning = "#a35406",
    warning_soft = "#fef3db",
    info = "#1f5fd6",
    info_soft = "#e7effe",
    -- PReview's light syntax tokens, in the same roles.
    keyword = "#6f3fd1",
    string = "#0a7a51",
    comment = "#737087",
    func = "#0b6bcb",
    type = "#a35406",
    number = "#c2252c",
    constant = "#0e7c66",
    ansi = {
      "#16141f", "#c2252c", "#0a7a51", "#a35406",
      "#1f5fd6", "#5235d6", "#0e7c66", "#5c5970",
      "#86839a", "#b42318", "#0a7a51", "#a35406",
      "#3557d4", "#6f3fd1", "#0b6bcb", "#e6e4ee",
    },
  },
}

local function overrides(p)
  -- UI groups on top of the theme. Backgrounds stay clear so Herdr's card shows through.
  return {
    Normal = { fg = p.text, bg = "NONE" },
    NormalNC = { fg = p.text, bg = "NONE" },
    SignColumn = { fg = p.text, bg = "NONE" },
    FoldColumn = { fg = p.text, bg = "NONE" },
    LineNr = { fg = p.dim, bg = "NONE" },
    NonText = { fg = p.dim, bg = "NONE" },
    Whitespace = { fg = p.dim, bg = "NONE" },
    EndOfBuffer = { fg = p.dim, bg = "NONE" },
    CursorLineNr = { fg = p.accent, bg = "NONE", bold = true },
    -- Clear like the pane. A filled cursor line made Herdr draw the line's text white.
    CursorLine = { bg = "NONE" },
    Cursor = { fg = p.cursor_text, bg = p.focus },
    Visual = { fg = p.text, bg = p.accent_soft },
    WinSeparator = { fg = p.border, bg = "NONE" },
    NormalFloat = { fg = p.text, bg = p.float },
    Pmenu = { fg = p.text, bg = p.float },
    FloatBorder = { fg = p.border, bg = p.float },
    FloatTitle = { fg = p.accent, bg = p.accent_soft, bold = true },
    PmenuSel = { fg = p.accent, bg = p.selected, bold = true },
    PmenuThumb = { bg = p.border },
    PmenuSbar = { bg = p.sunken },
    StatusLine = { fg = p.muted, bg = "NONE" },
    StatusLineNC = { fg = p.muted, bg = "NONE" },
    TabLineFill = { fg = p.muted, bg = "NONE" },
    TabLine = { fg = p.muted, bg = p.float },
    TabLineSel = { fg = p.accent, bg = p.accent_soft, bold = true },
    Directory = { fg = p.warning },
    HarpoonFilename = { fg = p.accent },
    HarpoonMenuNormal = { fg = p.text, bg = "NONE" },
    HarpoonMenuBorder = { fg = p.border, bg = "NONE" },
    HarpoonMenuTitle = { fg = p.accent, bg = "NONE", bold = true },
    SnacksPickerDirectory = { fg = p.text },
    SnacksPickerFile = { fg = p.text },
    WhichKey = { fg = p.accent },
    SnacksPickerDir = { fg = p.muted },
    SnacksPickerMatch = { fg = p.accent, bold = true },
    SnacksPickerListCursorLine = { fg = p.text, bg = "NONE", bold = true },
    SnacksPickerTitle = { fg = p.accent, bg = "NONE", bold = true },
    SnacksPickerToggle = { fg = p.info, bg = "NONE", bold = true },
    SnacksPickerHiddenCursor = { blend = 100, nocombine = true },
    -- Pickers and the explorer sit on the editor background, like harpoon,
    -- so rounded borders have no square corner cells.
    SnacksPicker = { fg = p.text, bg = "NONE" },
    SnacksPickerBox = { fg = p.text, bg = "NONE" },
    SnacksPickerList = { fg = p.text, bg = "NONE" },
    SnacksPickerInput = { fg = p.text, bg = "NONE" },
    SnacksPickerBorder = { fg = p.border, bg = "NONE" },
    SnacksPickerBoxBorder = { fg = p.border, bg = "NONE" },
    SnacksPickerInputBorder = { fg = p.border, bg = "NONE" },
    SnacksIndent = { fg = p.indent },
    SnacksIndentScope = { fg = p.border },
    -- Find and replace float: hairline border, accent only on matches.
    GrugFarFloatBorder = { fg = p.hairline, bg = p.float },
    GrugFarFloatTitle = { fg = p.text, bg = p.float, bold = true },
    GrugFarCursorLine = { bg = p.selected },
    GrugFarInputLabel = { fg = p.muted },
    GrugFarInputPlaceholder = { fg = p.faint },
    GrugFarResultsHeader = { fg = p.hover },
    GrugFarResultsStats = { fg = p.muted },
    GrugFarResultsActionMessage = { fg = p.muted },
    GrugFarResultsPath = { fg = p.text, bold = true },
    GrugFarFileRow = { bg = p.file_row },
    GrugFarFileRowDir = { fg = p.muted, bold = false },
    GrugFarResultsLineNr = { fg = p.faint },
    GrugFarResultsCursorLineNo = { fg = p.accent },
    GrugFarResultsLongLineStr = { fg = p.faint },
    GrugFarResultsMatch = { fg = p.accent, bg = p.accent_soft, bold = true },
    GrugFarResultsMatchAdded = { fg = p.success, bg = p.success_soft },
    GrugFarResultsMatchRemoved = { fg = p.danger, bg = p.danger_soft, strikethrough = true },
    GrugFarResultsChangeIndicator = { fg = p.accent },
    GrugFarResultsAddIndicator = { fg = p.success },
    GrugFarResultsRemoveIndicator = { fg = p.danger },
    GrugFarCurrentMatch = { fg = p.text, bg = p.border, bold = true },
    PreviewNormal = { fg = p.accent, bg = p.accent_soft, bold = true },
    PreviewInsert = { fg = p.success, bg = p.success_soft, bold = true },
    PreviewVisual = { fg = p.warning, bg = p.warning_soft, bold = true },
    PreviewReplace = { fg = p.danger, bg = p.danger_soft, bold = true },
    PreviewFile = { fg = p.text, bg = p.float, bold = true },
    PreviewInfo = { fg = p.info, bg = p.info_soft, bold = true },
    PreviewWarning = { fg = p.warning, bg = p.warning_soft, bold = true },
    PreviewError = { fg = p.danger, bg = p.danger_soft, bold = true },
    PreviewSuccess = { fg = p.success, bg = p.success_soft, bold = true },
    DiagnosticError = { fg = p.danger },
    DiagnosticVirtualTextError = { fg = p.danger, bg = p.danger_soft },
    DiagnosticSignError = { fg = p.danger, bg = "NONE" },
    DiagnosticWarn = { fg = p.warning },
    DiagnosticVirtualTextWarn = { fg = p.warning, bg = p.warning_soft },
    DiagnosticSignWarn = { fg = p.warning, bg = "NONE" },
    DiagnosticInfo = { fg = p.info },
    DiagnosticVirtualTextInfo = { fg = p.info, bg = p.info_soft },
    DiagnosticSignInfo = { fg = p.info, bg = "NONE" },
    DiagnosticHint = { fg = p.accent },
    DiagnosticVirtualTextHint = { fg = p.accent, bg = p.accent_soft },
    DiagnosticSignHint = { fg = p.accent, bg = "NONE" },
  }
end

-- Tourist's mapping: keyword ansi5, string ansi2, comment dim, function ansi4, type ansi3,
-- number ansi1, constant ansi6. Everything else is plain text.
local syntax = {
  keyword = {
    "Keyword", "Statement", "Conditional", "Repeat", "Label", "Exception",
    "Include", "PreProc", "Define", "Macro", "StorageClass",
    "@keyword", "@keyword.function", "@keyword.return", "@keyword.import",
    "@keyword.conditional", "@keyword.repeat", "@keyword.exception",
    "@keyword.operator", "@keyword.modifier", "@keyword.type", "@keyword.coroutine",
    "@conditional", "@repeat", "@include", "@exception",
  },
  string = { "String", "Character", "@string", "@character", "@string.special" },
  comment = { "Comment", "SpecialComment", "@comment", "@comment.documentation" },
  func = {
    "Function", "@function", "@function.call", "@function.builtin",
    "@function.method", "@function.method.call", "@method", "@method.call",
  },
  type = {
    "Type", "Structure", "Typedef", "@type", "@type.builtin", "@type.definition",
    "@constructor",
  },
  number = { "Number", "Float", "@number", "@number.float", "@float" },
  constant = {
    "Constant", "Boolean", "@constant", "@constant.builtin", "@boolean", "@string.escape",
  },
}

local plain = {
  "Identifier", "Operator", "Delimiter", "Special",
  "@variable", "@variable.member", "@variable.parameter", "@variable.builtin",
  "@property", "@field", "@parameter", "@module", "@namespace", "@label",
  "@operator", "@punctuation", "@punctuation.delimiter", "@punctuation.bracket",
  "@punctuation.special", "@tag", "@tag.attribute", "@tag.delimiter",
}

local function saved_mode()
  local file = io.open(MODE_FILE, "r")
  local mode = file and file:read("*l") or ""
  if file then file:close() end
  -- No file yet, or something unexpected in it: dark, as before light mode existed.
  return mode == "light" and "light" or "dark"
end

local current

local function apply(mode)
  if mode == current then return end
  current = mode
  local p = palettes[mode]
  vim.o.background = mode
  vim.cmd.colorscheme(p.base)
  for group, spec in pairs(overrides(p)) do
    vim.api.nvim_set_hl(0, group, spec)
  end
  for role, groups in pairs(syntax) do
    for _, group in ipairs(groups) do
      vim.api.nvim_set_hl(0, group, { fg = p[role] })
    end
  end
  for _, group in ipairs(plain) do
    vim.api.nvim_set_hl(0, group, { link = "Normal" })
  end
  for index, color in ipairs(p.ansi) do
    vim.g["terminal_color_" .. (index - 1)] = color
  end
  -- Its round caps take their color from the Preview* groups set above.
  require("config.statusline").setup()
end

-- Watches the mode file's folder: `theme` may replace the file, and a folder watch sees that too.
local function watch()
  local watcher = vim.uv.new_fs_event()
  if not watcher then return end
  watcher:start(vim.fn.fnamemodify(MODE_FILE, ":h"), {}, function(_, name)
    if name == vim.fn.fnamemodify(MODE_FILE, ":t") then
      vim.schedule(function() apply(saved_mode()) end)
    end
  end)
end

return {
  {
    "arzg/vim-colors-xcode",
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.termguicolors = true
      apply(saved_mode())
      watch()
    end,
  },
}
