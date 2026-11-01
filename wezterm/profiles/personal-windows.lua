local M = {}

function M.apply_to_config(config, wezterm)
  -- Docker Desktop registers internal distros (docker-desktop, docker-desktop-data)
  -- that are bare root shells with no dotfiles. Never use them as the default.
  for _, domain in ipairs(wezterm.default_wsl_domains()) do
    if not domain.distribution:match("^docker%-desktop") then
      config.default_domain = domain.name
      return
    end
  end
  wezterm.log_warn("No usable WSL distribution found; using the native Windows shell")
end

return M
