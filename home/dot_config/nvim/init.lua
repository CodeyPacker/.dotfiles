vim.g.mapleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Unable to install lazy.nvim: " .. output)
  end
  local lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json"
  if vim.fn.filereadable(lockfile) == 1 then
    local lock = vim.json.decode(table.concat(vim.fn.readfile(lockfile), "\n"))
    local pinned = lock["lazy.nvim"]
    if pinned then
      output = vim.fn.system({ "git", "-C", lazypath, "checkout", pinned.commit })
      if vim.v.shell_error ~= 0 then
        error("Unable to restore locked lazy.nvim: " .. output)
      end
    end
  end
end
vim.opt.rtp:prepend(lazypath)

require("config")
require("lazy").setup("plugins")
