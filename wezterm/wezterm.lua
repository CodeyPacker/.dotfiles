local wezterm = require("wezterm")

local config = wezterm.config_builder()
local target = wezterm.target_triple
local is_macos = target:find("apple%-darwin") ~= nil
local is_windows = target:find("windows") ~= nil

-- Use platform monospace fonts. Nerd Font icons fall
-- back to WezTerm's bundled Symbols Nerd Font. On Windows, install.ps1's
-- Hack Nerd Font comes first because the bundled one lacks newer icons.
if is_windows then
  config.font = wezterm.font_with_fallback({ "Consolas", "Hack Nerd Font" })
elseif is_macos then
  config.font = wezterm.font_with_fallback({ "SF Mono", "Menlo" })
else
  config.font = wezterm.font("Droid Sans Mono")
end
-- VS Code's 14px default; WezTerm sizes in points (14px = 10.5pt at 96 DPI).
config.font_size = 10.5
-- PReview Design System, dark palette:
-- https://claude.ai/artifact/3LLZ9hkaos5DgLxBP7bMca
config.window_background_opacity = 0.94
config.window_padding = { left = 20, right = 20, top = 16, bottom = 16 }
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true

-- Keep native title-bar controls with the same quiet surface as the tabs.
config.window_frame = {
  active_titlebar_bg = "#1b1a24", -- surface-solid
  inactive_titlebar_bg = "#14131b", -- surface-sunken
  active_titlebar_fg = "#f4f3f9", -- ink
  inactive_titlebar_fg = "#aba8bd", -- ink-secondary
}

config.colors = {
  foreground = "#f4f3f9", -- ink
  background = "#1b1a24", -- surface-solid
  cursor_bg = "#9c88ff", -- focus-ring
  cursor_fg = "#16141f", -- ink-inverse
  cursor_border = "#9c88ff",
  selection_bg = "#2b2452", -- accent-soft
  selection_fg = "#f4f3f9",
  split = "#4e3fa3", -- accent-border
  scrollbar_thumb = "#4e3fa3",
  compose_cursor = "#f8c15a", -- warning
  -- Standard ANSI roles use the design's status colors. Bright variants use
  -- its syntax colors, keeping red/green diff output and blue links familiar.
  ansi = {
    "#14131b", "#ff7b7f", "#45d69a", "#f8c15a",
    "#86afff", "#b5a6ff", "#5fd3b0", "#aba8bd",
  },
  brights = {
    "#8c89a0", "#ff9c8f", "#45d69a", "#f8c15a",
    "#8fb0ff", "#c4a7ff", "#6cc4ff", "#f4f3f9",
  },
  tab_bar = {
    background = "#0e0d14", -- canvas
    active_tab = { bg_color = "#29234a", fg_color = "#b5a6ff" },
    inactive_tab = { bg_color = "#1b1a24", fg_color = "#aba8bd" },
    inactive_tab_hover = { bg_color = "#2a2837", fg_color = "#f4f3f9" },
    new_tab = { bg_color = "#0e0d14", fg_color = "#aba8bd" },
    new_tab_hover = { bg_color = "#2b2452", fg_color = "#b5a6ff" },
  },
}

if is_macos then
  config.font_dirs = {
    wezterm.home_dir .. "/Library/Fonts",
    "/System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts",
  }
  config.font_size = 12
  config.line_height = 1.15
  config.default_cursor_style = "SteadyBar"
  config.window_background_opacity = 0.85
  config.macos_window_background_blur = 40
  config.window_padding = { left = 24, right = 24, top = 20, bottom = 20 }
  -- A single toolbar keeps the traffic lights alongside the tabs.
  config.window_decorations = "INTEGRATED_BUTTONS|RESIZE|MACOS_FORCE_ENABLE_SHADOW"
  config.hide_tab_bar_if_only_one_tab = false
  config.window_frame.font = wezterm.font("Helvetica Neue", { weight = "Medium" })
  config.window_frame.font_size = 12
elseif is_windows then
  -- Without this, WezTerm falls back to %COMSPEC% (cmd.exe) when no WSL
  -- domain is available, which has none of the dotfiles aliases/profile
  -- (no `ls`, no `vim`, etc). Use PowerShell 7 instead.
  config.default_prog = { "pwsh.exe", "-NoLogo" }
end

-- VS Code's Cmd+Shift+F/H. Terminals can't pass Cmd through to Neovim, so
-- send Alt+Shift+F/H, which Neovim maps to project find/replace.
config.keys = config.keys or {}
for _, key in ipairs({ "f", "h" }) do
  table.insert(config.keys, {
    key = key,
    mods = "SUPER|SHIFT",
    action = wezterm.action.SendKey({ key = key:upper(), mods = "ALT" }),
  })
end

-- Drag by holding Ctrl+Shift anywhere in the pane, in addition to the
-- title bar or integrated tab bar.
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

-- Dim unfocused windows so the active workspace stays visually obvious.
local UNFOCUSED_FOREGROUND_TEXT_HSB = { hue = 1.0, saturation = 0.25, brightness = 0.45 }
local UNFOCUSED_WINDOW_BACKGROUND_OPACITY = math.min(config.window_background_opacity, 0.9)

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
