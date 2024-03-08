return {
  { "tpope/vim-commentary" }, -- existing plugin

  -- nvim-tree with detailed configuration
  {
    "kyazdani42/nvim-tree.lua",
    config = function()
      -- Change color for arrows in tree to light blue
      vim.cmd([[ highlight NvimTreeIndentMarker guifg=#3FC5FF ]])

      require("nvim-tree").setup({
        renderer = {
          icons = {
            glyphs = {
              folder = {
                arrow_closed = "", -- arrow when folder is closed
                arrow_open = "", -- arrow when folder is open
              },
            },
          },
          group_empty = true, -- group empty folders together
        },
        actions = {
          open_file = {
            window_picker = {
              enable = false, -- disable window_picker
            },
          },
        },
        filters = {
          dotfiles = true, -- show dotfiles
        },
        view = {
          width = 30, -- set the view width to 30
        },
        -- Uncomment the following if you want to enable git integration
        -- git = {
        --   ignore = false, -- show files ignored by git
        -- },
      })

      -- Key mapping to toggle nvim-tree
      vim.api.nvim_set_keymap("n", "<Leader>b", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
    end,
  },
}
