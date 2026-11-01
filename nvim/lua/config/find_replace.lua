-- VS Code style project find/replace on top of grug-far, shown in a float.
local M = {}

local INSTANCE = "find"
-- VS Code defaults: literal text, case-insensitive.
local DEFAULT_FLAGS = "--ignore-case --fixed-strings"
local PRESERVE_CASE = "preserve-case"

-- Folder to search, like a VS Code workspace: the explorer's root if it is
-- open, else the current file's git repo, else Neovim's cwd.
local root

local function project_root()
  local explorer = Snacks.picker.get({ source = "explorer" })[1]
  if explorer then
    return explorer:cwd()
  end
  local file = vim.api.nvim_buf_get_name(0)
  return (file ~= "" and vim.fs.root(file, ".git")) or vim.fn.getcwd()
end

-- Opens a centered float. grug-far runs this as its windowCreationCommand
-- and then puts its own buffer in the current window. grug-far runs rg from
-- getcwd(), so give the float a window-local cwd.
function M.float()
  local width = math.floor(vim.o.columns * 0.85)
  local height = math.floor((vim.o.lines - vim.o.cmdheight) * 0.85)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
    title = " Find and Replace ",
    title_pos = "center",
  })
  vim.wo[win].winhighlight =
    "FloatBorder:GrugFarFloatBorder,FloatTitle:GrugFarFloatTitle,CursorLine:GrugFarCursorLine"
  vim.wo[win].cursorline = true
  vim.cmd.lcd(vim.fn.fnameescape(root))
end

-- Same rules as VS Code: ALL CAPS, all lower, or Capitalized match.
local function preserve_case(match, text)
  if match:upper() == match and match:lower() ~= match then
    return text:upper()
  elseif match:lower() == match and match:upper() ~= match then
    return text:lower()
  elseif match:sub(1, 1):match("%u") then
    return text:sub(1, 1):upper() .. text:sub(2)
  end
  return text
end

-- grug-far only knows its built-in interpreters, so add ours to its lookup.
function M.register_preserve_case()
  local interpreters = require("grug-far.replacementInterpreter")
  local get = interpreters.getReplacementInterpreter
  interpreters.getReplacementInterpreter = function(type)
    if type == PRESERVE_CASE then
      return {
        type = PRESERVE_CASE,
        get_eval_fn = function(text)
          return function(match)
            return preserve_case(match, text)
          end
        end,
      }
    end
    return get(type)
  end
end

local function selected_text()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
    return lines[1] or ""
  end
  return vim.fn.expand("<cword>")
end

-- input: "search" or "replacement", the field to put the cursor in.
function M.open(input)
  local grug = require("grug-far")
  root = project_root()
  local search = selected_text()
  local inst
  if grug.has_instance(INSTANCE) then
    inst = grug.get_instance(INSTANCE)
    inst:open()
    if search ~= "" then
      inst:update_input_values({ search = search }, false)
    else
      -- The root may have changed since the last search.
      inst:search()
    end
  else
    inst = grug.open({
      instanceName = INSTANCE,
      prefills = { search = search, flags = DEFAULT_FLAGS },
    })
  end
  vim.schedule(function()
    inst:goto_input(input)
    vim.cmd("startinsert!")
  end)
end

local function toggle_flag(flag)
  return function()
    require("grug-far").get_instance(0):toggle_flags({ flag })
  end
end

local function toggle_preserve_case()
  local inst = require("grug-far").get_instance(0)
  -- _params is grug-far's internal { buf, context }. There is no public API
  -- to set an interpreter by name.
  local params = inst._params
  local current = params.context.replacementInterpreter
  local next_type = (current and current.type == PRESERVE_CASE) and "default" or PRESERVE_CASE
  require("grug-far.replacementInterpreter").setReplacementInterpreter(params.buf, params.context, next_type)
  -- Interpreters switch grug-far to search-on-InsertLeave. Keep it live.
  params.context.state.normalModeSearch = false
  require("grug-far.actions.search")(params)
end

-- Jump to the result and hide the float so the file is visible.
local function goto_and_hide()
  local inst = require("grug-far").get_instance(0)
  local float = vim.api.nvim_get_current_win()
  inst:goto_location()
  if vim.api.nvim_get_current_win() ~= float then
    vim.api.nvim_win_close(float, true)
  end
end

-- 0-based rows of the result group under the cursor: the file path line
-- through its last match line. nil when the cursor is not on a result.
local function file_group(params)
  local results = require("grug-far.render.resultsList")
  local buf, context = params.buf, params.context
  local function header(row)
    local loc = results.getResultLocation(row, buf, context)
    return loc and loc.filename and not loc.lnum
  end
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  if not results.getResultLocation(row, buf, context) then
    return nil
  end
  local first = row
  while first > 0 and not header(first) do
    first = first - 1
  end
  local last_line = vim.api.nvim_buf_line_count(buf) - 1
  local last = first
  for r = first + 1, last_line do
    if header(r) then
      break
    end
    if results.getResultLocation(r, buf, context) then
      last = r
    end
  end
  return first, last
end

-- Removes the group and the blank line above it, then puts the cursor on
-- the next file.
local function drop_group(params, first, last)
  local start = first
  if first > 0 and vim.api.nvim_buf_get_lines(params.buf, first - 1, first, false)[1] == "" then
    start = first - 1
  end
  vim.api.nvim_buf_set_lines(params.buf, start, last + 1, false, {})
  local line_count = vim.api.nvim_buf_line_count(params.buf)
  vim.api.nvim_win_set_cursor(0, { math.min(start + 2, line_count), 0 })
end

-- VS Code's per-file Replace All: write this file's replacements, then
-- remove it from the list.
local function replace_file()
  local params = require("grug-far").get_instance(0)._params
  local first, last = file_group(params)
  if not first then
    return
  end
  require("grug-far.actions.sync")({
    buf = params.buf,
    context = params.context,
    startRow = first,
    endRow = last,
    on_success = vim.schedule_wrap(function()
      drop_group(params, first, last)
    end),
  })
end

-- VS Code's Dismiss: remove this file from the list without changing it.
local function skip_file()
  local params = require("grug-far").get_instance(0)._params
  local first, last = file_group(params)
  if first then
    drop_group(params, first, last)
  end
end

-- Moves the cursor to the first match of the next (1) or previous (-1) file.
local function jump_file(step)
  return function()
    local params = require("grug-far").get_instance(0)._params
    local results = require("grug-far.render.resultsList")
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local first = file_group(params)
    -- Going back from inside a file skips past that file's own name row.
    local from = (step < 0 and first) and first or row
    local last_line = vim.api.nvim_buf_line_count(params.buf) - 1
    for r = from + step, step > 0 and last_line or 0, step do
      local loc = results.getResultLocation(r, params.buf, params.context)
      if loc and loc.filename and not loc.lnum then
        vim.api.nvim_win_set_cursor(0, { r + 2, 0 })
        return
      end
    end
  end
end

-- Paints each file name row as a full-width band, with the folder part
-- dimmed, so every file's results read as one group.
function M.setup_file_rows()
  local ns = vim.api.nvim_create_namespace("find_replace_file_rows")
  local results = require("grug-far.render.resultsList")
  local painted = {} -- buf -> changedtick last painted

  local function paint(buf)
    local inst = require("grug-far").get_instance(buf)
    if not (inst and vim.api.nvim_buf_is_valid(buf)) then
      return
    end
    local context = inst._params.context
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    for row, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
      local loc = results.getResultLocation(row - 1, buf, context)
      if loc and loc.filename and not loc.lnum then
        vim.api.nvim_buf_set_extmark(buf, ns, row - 1, 0, {
          line_hl_group = "GrugFarFileRow",
          -- A blank sign in the band color pads the icon from the edge.
          sign_text = " ",
          sign_hl_group = "GrugFarFileRow",
        })
        local dir_end = line:find("[^/]*$") - 1
        if dir_end > 0 then
          vim.api.nvim_buf_set_extmark(buf, ns, row - 1, 0, {
            end_col = dir_end,
            hl_group = "GrugFarFileRowDir",
            priority = 5000,
          })
        end
      end
    end
  end

  -- grug-far renders results in async chunks. Repaint after any redraw of
  -- a buffer whose text changed since the last paint.
  vim.api.nvim_set_decoration_provider(ns, {
    on_win = function(_, _, buf)
      if vim.bo[buf].filetype == "grug-far" then
        local tick = vim.b[buf].changedtick
        if painted[buf] ~= tick then
          painted[buf] = tick
          vim.schedule(function()
            paint(buf)
          end)
        end
      end
      return false
    end,
  })
end

local function hide()
  require("grug-far").get_instance(0):hide()
end

function M.setup_buffer(buf)
  local function map(modes, lhs, rhs, desc)
    vim.keymap.set(modes, lhs, rhs, { buffer = buf, desc = desc })
  end
  map({ "n", "i" }, "<M-c>", toggle_flag("--ignore-case"), "Toggle Match Case")
  map({ "n", "i" }, "<M-w>", toggle_flag("--word-regexp"), "Toggle Whole Word")
  map({ "n", "i" }, "<M-r>", toggle_flag("--fixed-strings"), "Toggle Regex")
  map({ "n", "i" }, "<M-p>", toggle_preserve_case, "Toggle Preserve Case")
  map({ "n", "i" }, "<M-CR>", function() require("grug-far").get_instance(0):replace() end, "Replace All")
  map("n", "R", replace_file, "Replace in This File")
  map("n", "X", skip_file, "Skip This File")
  map("n", "]]", jump_file(1), "Next File")
  map("n", "[[", jump_file(-1), "Previous File")
  map("n", "<CR>", goto_and_hide, "Go To Result")
  map("n", "q", hide, "Hide Find and Replace")
  map("n", "<Esc>", hide, "Hide Find and Replace")
end

return M
