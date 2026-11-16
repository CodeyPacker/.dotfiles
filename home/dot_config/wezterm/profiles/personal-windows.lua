local M = {}

function M.apply_to_config(config, wezterm)
  local domains = wezterm.default_wsl_domains()
  if #domains > 0 then
    config.default_domain = domains[1].name
  else
    wezterm.log_warn("No WSL distribution found; using the native Windows shell")
  end
end

return M
