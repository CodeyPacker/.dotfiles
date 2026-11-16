local M = {}
local uname = vim.uv.os_uname()

M.is_macos = uname.sysname == "Darwin"
M.is_windows = uname.sysname:find("Windows") ~= nil
  or uname.sysname:find("MINGW") ~= nil
M.is_wsl = uname.release:lower():find("microsoft") ~= nil

M.profile = os.getenv("DOTFILES_PROFILE")
if not M.profile or M.profile == "" then
  local profile_path = vim.fn.expand("~/.config/dotfiles/profile")
  if vim.fn.filereadable(profile_path) == 1 then
    M.profile = vim.trim(table.concat(vim.fn.readfile(profile_path), ""))
  elseif M.is_windows or M.is_wsl then
    M.profile = "personal-windows"
  elseif M.is_macos then
    M.profile = "personal-mac"
  else
    M.profile = "linux"
  end
end

return M
