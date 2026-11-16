local M = {}

-- Used by chezmoi after restoring the locked plugins. Mason's automatic
-- ensure_installed is disabled in headless sessions, so wait for installs here.
function M.install()
  local lazy_config = require("lazy.core.config")
  local lock = vim.json.decode(table.concat(vim.fn.readfile(lazy_config.options.lockfile), "\n"))
  local count = 0
  for name, pinned in pairs(lock) do
    local plugin = assert(lazy_config.plugins[name], "Unknown locked plugin: " .. name)
    local head = vim.fn.systemlist({ "git", "-C", plugin.dir, "rev-parse", "HEAD" })
    assert(vim.v.shell_error == 0 and head[1] == pinned.commit, "Plugin not restored to its lock: " .. name)
    count = count + 1
  end
  print("Verified " .. count .. " locked plugins.")
  require("lazy").load({ plugins = { "nvim-lspconfig" } })
  local registry = require("mason-registry")
  local refreshed, refresh_ok = false, false
  registry.refresh(function(ok)
    refresh_ok = ok
    refreshed = true
  end)
  assert(vim.wait(120000, function() return refreshed end, 100), "Mason registry refresh timed out")
  assert(refresh_ok, "Mason registry refresh failed")

  local mapping = require("mason-lspconfig").get_mappings().lspconfig_to_package
  local pending, failed = {}, {}
  local servers = vim.tbl_keys(require("config.lsp_servers"))
  table.sort(servers)
  for _, server in ipairs(servers) do
    local name = assert(mapping[server], "No Mason package for " .. server)
    local package = registry.get_package(name)
    if not package:is_installed() then
      pending[name] = true
      package:once("install:success", function()
        pending[name] = nil
        print("Installed " .. name)
      end)
      package:once("install:failed", function()
        pending[name] = nil
        failed[name] = true
      end)
      print("Installing " .. name)
      package:install()
    end
  end
  assert(vim.wait(600000, function() return next(pending) == nil end, 100), "Language server installation timed out")
  assert(next(failed) == nil, "Failed Mason packages: " .. table.concat(vim.tbl_keys(failed), ", "))
  for _, server in ipairs(servers) do
    assert(registry.get_package(mapping[server]):is_installed(), "Missing language server: " .. server)
  end
  print("All " .. #servers .. " configured language servers installed.")
end

function M.run()
  local ok, err = xpcall(M.install, debug.traceback)
  if not ok then
    vim.api.nvim_err_writeln(err)
    vim.cmd("cquit 1")
    return
  end
  vim.cmd("qall")
end

return M
