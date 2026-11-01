vim.api.nvim_create_autocmd("FileType", {
  pattern = "harpoon",
  callback = function()
    vim.opt_local.cursorline = true
    vim.api.nvim_set_hl(0, "HarpoonWindow", { link = "NormalFloat" })
    vim.api.nvim_set_hl(0, "HarpoonBorder", { link = "FloatBorder" })
  end,
})
