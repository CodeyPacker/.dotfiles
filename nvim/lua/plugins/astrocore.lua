-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 },
      autopairs = true,
      cmp = true,
      diagnostics_mode = 3,
      highlighturl = true,
      notifications = true,
    },
    -- Diagnostics configuration
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options
    options = {
      opt = {
        relativenumber = false,
        number = true,
        spell = false,
        signcolumn = "yes",
        wrap = false,
        clipboard = "unnamedplus",
      },
      g = {
        -- configure global vim variables
      },
    },
    -- Mappings
    mappings = {
      -- Normal mode mappings
      n = {
        -- Toggle Neo-tree
        ["<Leader>a"] = { ":Neotree toggle<CR>", desc = "Toggle Neo-tree" },

        -- Format current file
        ["<Leader>fm"] = {
          function() vim.lsp.buf.format { async = true } end,
          desc = "Format current file",
        },
      },

      -- Insert mode mappings
      i = {
        ["jk"] = { "<Esc>", desc = "Escape to normal mode" },
        ["<C-v>"] = { '<Esc>"+pa', desc = "Paste from system clipboard" },
      },

      -- Terminal mode mappings
      t = {
        -- This is needed to close the floating terminal while keeping it's state the next time it's opened
        ["<Leader>t"] = { "<C-\\><C-n>:ToggleTerm direction=float<CR>", desc = "Toggle terminal buffer" },
        ["<Esc>"] = { "<C-\\><C-n>:ToggleTerm direction=float<CR>", desc = "Toggle terminal buffer" },
        -- ["<Esc>"] = { [[<C-\><C-n>]], desc = "Exit terminal mode" },
      },

      -- v = {},
    },
  },
}
