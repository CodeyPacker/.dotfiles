local M = {}

local function tag(group, text)
  return "%#Preview" .. group .. "# " .. text .. " %#StatusLine# "
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

  local parts = { tag(group, label), tag("File", "%<%t") }
  if vim.bo.modified then
    parts[#parts + 1] = tag("Warning", "modified")
  end
  if vim.bo.readonly then
    parts[#parts + 1] = tag("Warning", "read only")
  end

  local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
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
  vim.opt.termguicolors = true
  vim.opt.laststatus = 3
  vim.opt.showmode = false
  vim.opt.statusline = "%!v:lua.require('config.statusline').render()"
end

return M
