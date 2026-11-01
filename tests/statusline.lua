-- Run: nvim --headless -u NONE -i NONE -l tests/statusline.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.runtimepath:prepend(root .. "/nvim")
vim.diagnostic.config({ virtual_text = false, signs = false, underline = false })

local statusline = require("config.statusline")
local severity = vim.diagnostic.severity
local first = vim.api.nvim_get_current_buf()
local ns = vim.api.nvim_create_namespace("statusline-test")
local other_ns = vim.api.nvim_create_namespace("statusline-test-other")

-- Setup must pick up diagnostics that existed before the status line loaded.
vim.diagnostic.set(ns, first, {
  { lnum = 0, col = 0, message = "Error", severity = severity.ERROR },
  { lnum = 0, col = 0, message = "Warning", severity = severity.WARN },
})
statusline.setup()
assert(statusline.render():find("1 error"))
assert(statusline.render():find("1 warning"))

-- Cursor movement and redraws must not scan diagnostics again.
local count = vim.diagnostic.count
local calls = 0
vim.diagnostic.count = function(...)
  calls = calls + 1
  return count(...)
end
for _ = 1, 100 do
  statusline.render()
end
assert(calls == 0, "Redraws should use cached counts")

-- Counts must include every namespace, not just the last changed source.
vim.diagnostic.set(other_ns, first, {
  { lnum = 0, col = 0, message = "Other error", severity = severity.ERROR },
})
assert(statusline.render():find("2 errors"))
vim.diagnostic.reset(ns, first)
assert(statusline.render():find("1 error"))
assert(not statusline.render():find("warning"))

-- Switching buffers must not reuse another buffer's counts.
local second = vim.api.nvim_create_buf(true, false)
vim.api.nvim_set_current_buf(second)
assert(not statusline.render():find("error"))
vim.api.nvim_set_current_buf(first)
assert(statusline.render():find("1 error"))
vim.diagnostic.reset(other_ns, first)
assert(not statusline.render():find("error"))

-- Repeated setup must replace handlers rather than registering duplicates.
statusline.setup()
statusline.render()
calls = 0
vim.diagnostic.set(ns, first, {
  { lnum = 0, col = 0, message = "Updated error", severity = severity.ERROR },
})
assert(calls == 1, "Setup should register one diagnostic handler")
assert(statusline.render():find("1 error"))
vim.diagnostic.count = count
print("Status line checks passed")
vim.cmd("qa!")
