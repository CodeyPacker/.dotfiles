local wezterm = require("wezterm")

local config = wezterm.config_builder()
local target = wezterm.target_triple
local is_macos = target:find("apple%-darwin") ~= nil
local is_windows = target:find("windows") ~= nil

config.color_scheme = "rose-pine-moon"
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 15.0
config.window_background_opacity = 0.8
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

if is_macos then
  config.font_dirs = { wezterm.home_dir .. "/Library/Fonts" }
  config.macos_window_background_blur = 50
elseif is_windows then
  config.win32_system_backdrop = "Acrylic"
end

local function file_exists(path)
  local file = io.open(path, "r")
  if file then
    file:close()
    return true
  end
  return false
end

local function apply_overlay(path, label)
  if not file_exists(path) then
    return
  end

  local ok, overlay = pcall(dofile, path)
  if not ok then
    wezterm.log_error("Unable to load " .. label .. ": " .. tostring(overlay))
    return
  end

  if type(overlay) == "function" then
    overlay(config, wezterm)
  elseif type(overlay) == "table" and type(overlay.apply_to_config) == "function" then
    overlay.apply_to_config(config, wezterm)
  else
    wezterm.log_error(label .. " must return a function or an apply_to_config module")
  end
end

local profile = os.getenv("DOTFILES_PROFILE")
if not profile or profile == "" then
  if is_windows then
    profile = "personal-windows"
  elseif is_macos then
    profile = "personal-mac"
  else
    profile = "linux"
  end
end

if profile:match("^[%w_-]+$") then
  apply_overlay(wezterm.config_dir .. "/profiles/" .. profile .. ".lua", "profile " .. profile)
else
  wezterm.log_error("Ignoring invalid DOTFILES_PROFILE value: " .. profile)
end

apply_overlay(
  wezterm.home_dir .. "/.config/dotfiles/wezterm.local.lua",
  "machine-local WezTerm override"
)

-- Dim unfocused windows so the active workspace stays visually obvious.
local UNFOCUSED_FOREGROUND_TEXT_HSB = { hue = 1.0, saturation = 0.25, brightness = 0.45 }
local UNFOCUSED_WINDOW_BACKGROUND_OPACITY = 0.62

local function same_text_hsb(actual, expected)
  if actual == nil or expected == nil then
    return actual == expected
  end
  return actual.hue == expected.hue
    and actual.saturation == expected.saturation
    and actual.brightness == expected.brightness
end

wezterm.on("window-focus-changed", function(window)
  local overrides = window:get_config_overrides() or {}
  local text_hsb, opacity
  if not window:is_focused() then
    text_hsb = UNFOCUSED_FOREGROUND_TEXT_HSB
    opacity = UNFOCUSED_WINDOW_BACKGROUND_OPACITY
  end

  if same_text_hsb(overrides.foreground_text_hsb, text_hsb)
      and overrides.window_background_opacity == opacity then
    return
  end

  overrides.foreground_text_hsb = text_hsb
  overrides.window_background_opacity = opacity
  window:set_config_overrides(overrides)
end)

return config
