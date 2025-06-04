return {
  "AstroNvim/astrotheme",
  priority = 1000, -- ensure it's loaded early
  config = function()
    require("astrotheme").setup {
      style = {
        transparent = true, -- 🔥 this enables transparency
      },
    }
    vim.cmd.colorscheme "astrotheme"
  end,
}
