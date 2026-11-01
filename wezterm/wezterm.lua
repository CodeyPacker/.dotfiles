local wezterm = require("wezterm")

local config = wezterm.config_builder()
local target = wezterm.target_triple
local is_macos = target:find("apple%-darwin") ~= nil
local is_windows = target:find("windows") ~= nil

-- Match VS Code's default editor font per platform. Nerd Font icons fall
-- back to WezTerm's bundled Symbols Nerd Font. On Windows, install.ps1's
-- Hack Nerd Font comes first because the bundled one lacks newer icons.
if is_windows then
  config.font = wezterm.font_with_fallback({ "Consolas", "Hack Nerd Font" })
elseif is_macos then
  config.font = wezterm.font("Menlo")
else
  config.font = wezterm.font("Droid Sans Mono")
end
-- VS Code's 14px default; WezTerm sizes in points (14px = 10.5pt at 96 DPI).
config.font_size = 10.5
config.window_background_opacity = 1
config.hide_tab_bar_if_only_one_tab = true

-- The fancy tab bar renders as part of the OS title bar (window_frame
-- colors) and ignores window_background_opacity, so it stays opaque no
-- matter what colors.tab_bar below says. The retro tab bar is drawn inside
-- the window surface instead and does respect it.
config.use_fancy_tab_bar = false

-- VS Code "Dark 2026" integrated terminal colors (ANSI values are VS Code's
-- built-in terminal defaults, which the theme does not override).
config.colors = {
  foreground = "#cccccc",
  background = "#191a1b",
  cursor_bg = "#bfbfbf",
  cursor_fg = "#191a1b",
  cursor_border = "#bfbfbf",
  selection_bg = "#264352",
  selection_fg = "none",
  split = "#2a2b2c",
  ansi = { "#000000", "#cd3131", "#0dbc79", "#e5e510", "#2472c8", "#bc3fbc", "#11a8cd", "#e5e5e5" },
  brights = { "#666666", "#f14c4c", "#23d18b", "#f5f543", "#3b8eea", "#d670d6", "#29b8db", "#e5e5e5" },
  tab_bar = {
    background = "rgba(0, 0, 0, 0)",
    active_tab = { bg_color = "rgba(0, 0, 0, 0)", fg_color = "#bfbfbf" },
    inactive_tab = { bg_color = "rgba(0, 0, 0, 0)", fg_color = "#8c8c8c" },
    inactive_tab_hover = { bg_color = "rgba(0, 0, 0, 0)", fg_color = "#bfbfbf" },
    new_tab = { bg_color = "rgba(0, 0, 0, 0)", fg_color = "#8c8c8c" },
    new_tab_hover = { bg_color = "rgba(0, 0, 0, 0)", fg_color = "#bfbfbf" },
  },
}

if is_macos then
  config.font_dirs = { wezterm.home_dir .. "/Library/Fonts" }
  config.macos_window_background_blur = 50
elseif is_windows then
  -- Without this, WezTerm falls back to %COMSPEC% (cmd.exe) when no WSL
  -- domain is available, which has none of the dotfiles aliases/profile
  -- (no `ls`, no `vim`, etc). Use PowerShell 7 instead.
  config.default_prog = { "pwsh.exe", "-NoLogo" }
end

-- The OS title bar (window_decorations defaults to "TITLE|RESIZE") already
-- gives native drag-by-titlebar and the min/max/close buttons. This extra
-- binding lets you also drag by holding Ctrl+Shift anywhere in the pane.
--
-- It has to fire on *Down* rather than WezTerm's built-in Drag-based
-- CTRL-SHIFT+drag binding, because tmux (mouse on) and other
-- mouse-reporting apps swallow the drag motion before that binding sees it
-- -- SHIFT only bypasses reporting capture, it doesn't stop the app from
-- consuming the drag itself. Starting the drag-follow state on the initial
-- click sidesteps that; `mouse_reporting = true` keeps it firing even while
-- an app has mouse reporting enabled.
config.mouse_bindings = config.mouse_bindings or {}
table.insert(config.mouse_bindings, {
  event = { Down = { streak = 1, button = "Left" } },
  mods = "CTRL|SHIFT",
  mouse_reporting = true,
  action = wezterm.action.StartWindowDrag,
})

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

-- Open the first window inset by a fixed percentage of the active screen on
-- every machine, regardless of resolution. Width and height insets differ
-- because equal-percentage insets look side-heavy on a widescreen monitor.
local STARTUP_SCREEN_WIDTH_INSET = 0.05
local STARTUP_SCREEN_HEIGHT_INSET = 0.1

wezterm.on("gui-startup", function(cmd)
  local screen = wezterm.gui.screens().active
  local width = math.floor(screen.width * (1 - STARTUP_SCREEN_WIDTH_INSET * 2))
  local height = math.floor(screen.height * (1 - STARTUP_SCREEN_HEIGHT_INSET * 2))

  local _, _, window = wezterm.mux.spawn_window(cmd or {})
  local gui_window = window:gui_window()
  gui_window:set_inner_size(width, height)
  gui_window:set_position(
    screen.x + math.floor((screen.width - width) / 2),
    screen.y + math.floor((screen.height - height) / 2)
  )
end)

-- Shrink the font while nvim is the foreground process in the active pane,
-- then restore it once nvim exits. Captured after profile/local overlays run
-- so it reflects whatever font_size they may have set.
local DEFAULT_FONT_SIZE = config.font_size
local NVIM_FONT_SIZE = DEFAULT_FONT_SIZE - 2

local function is_nvim(process_name)
  if not process_name then
    return false
  end
  return process_name:find("[/\\]nvim%.?e?x?e?$") ~= nil
end

wezterm.on("update-status", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local target_size = is_nvim(pane:get_foreground_process_name()) and NVIM_FONT_SIZE or nil

  if overrides.font_size == target_size then
    return
  end

  overrides.font_size = target_size
  window:set_config_overrides(overrides)
end)

-- Dim unfocused windows so the active workspace stays visually obvious.
local UNFOCUSED_FOREGROUND_TEXT_HSB = { hue = 1.0, saturation = 0.25, brightness = 0.45 }
local UNFOCUSED_WINDOW_BACKGROUND_OPACITY = 0.9

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
