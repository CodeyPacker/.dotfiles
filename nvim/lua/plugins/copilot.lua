return {
  "github/copilot.vim",
  init = function()
    vim.g.copilot_no_tab_map = true
  end,
  config = function()
    vim.keymap.set("i", "<C-;>", 'copilot#Accept("\\<CR>")', {
      expr = true,
      replace_keycodes = false,
      silent = true,
      desc = "Copilot accept",
    })
    vim.keymap.set("i", "<C-_>", "<Plug>(copilot-dismiss)", {
      silent = true,
      desc = "Copilot dismiss",
    })
  end,
}
