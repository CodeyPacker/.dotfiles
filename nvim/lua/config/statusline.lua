local M = {}
local diagnostic_counts = {}

local function diagnostics(bufnr)
  if not diagnostic_counts[bufnr] then
    diagnostic_counts[bufnr] = vim.diagnostic.count(bufnr)
  end
  return diagnostic_counts[bufnr]
end

local groups = { "Normal", "Insert", "Visual", "Replace", "File", "Info", "Warning", "Error" }

-- Round end caps: the tag's background color drawn as text on the bar.
local function set_cap_highlights()
  for _, group in ipairs(groups) do
    local hl = vim.api.nvim_get_hl(0, { name = "Preview" .. group, link = false })
    vim.api.nvim_set_hl(0, "Preview" .. group .. "Cap", { fg = hl.bg })
  end
end

local function tag(group, text)
  local cap = "%#Preview" .. group .. "Cap#"
  return cap .. "\u{e0b6}%#Preview" .. group .. "#" .. text .. cap .. "\u{e0b4}%#StatusLine# "
end

function M.render()
  local mode = vim.api.nvim_get_mode().mode
  local label, group = "NORMAL", "Normal"
  if mode:match("^i") then
    label, group = "INSERT", "Insert"
  elseif mode:match("^R") then
    label, group = "REPLACE", "Replace"
  elseif mode:match("^[vVsS]") or mode == "\22" or mode == "\19" then
    label, group = "VISUAL", "Visual"
  elseif mode:match("^c") then
    label = "COMMAND"
  elseif mode:match("^t") then
    label, group = "TERMINAL", "Insert"
  end

  -- The harpoon menu is a scratch buffer with a generated name that always reads as modified.
  local harpoon = vim.bo.filetype == "harpoon"
  local parts = { tag(group, label), tag("File", harpoon and "Harpoon" or "%<%t") }
  if vim.bo.modified and not harpoon then
    parts[#parts + 1] = tag("Warning", "modified")
  end
  if vim.bo.readonly then
    parts[#parts + 1] = tag("Warning", "read only")
  end

  local counts = diagnostics(vim.api.nvim_get_current_buf())
  local errors = counts[vim.diagnostic.severity.ERROR] or 0
  local warnings = counts[vim.diagnostic.severity.WARN] or 0
  if errors > 0 then
    parts[#parts + 1] = tag("Error", errors .. (errors == 1 and " error" or " errors"))
  end
  if warnings > 0 then
    parts[#parts + 1] = tag("Warning", warnings .. (warnings == 1 and " warning" or " warnings"))
  end
  parts[#parts + 1] = "%="
  if vim.bo.filetype ~= "" then
    parts[#parts + 1] = tag("Info", vim.bo.filetype:gsub("%%", "%%%%"))
  end
  parts[#parts + 1] = tag("File", "%l:%c")
  return table.concat(parts)
end

function M.setup()
  diagnostic_counts = {}
  local group = vim.api.nvim_create_augroup("PreviewStatusline", { clear = true })
  set_cap_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = set_cap_highlights })
  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = group,
    callback = function(args)
      diagnostic_counts[args.buf] = vim.diagnostic.count(args.buf)
      vim.cmd.redrawstatus()
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    callback = function(args)
      diagnostic_counts[args.buf] = nil
    end,
  })
  vim.opt.termguicolors = true
  vim.opt.laststatus = 3
  vim.opt.showmode = false
  vim.opt.statusline = "%!v:lua.require('config.statusline').render()"
end

return M
