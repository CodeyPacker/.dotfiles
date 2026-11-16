require("config.options")
require("config.autocmds")
require("config.keymaps")

local local_config = vim.fn.expand("~/.config/dotfiles/nvim.local.lua")
if vim.fn.filereadable(local_config) == 1 then
  local ok, err = pcall(dofile, local_config)
  if not ok then
    vim.schedule(function()
      vim.notify("Unable to load local Neovim config: " .. err, vim.log.levels.ERROR)
    end)
  end
end
