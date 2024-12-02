---@type LazySpec
return {

  -- == Examples of Adding Plugins ==

  "andweeb/presence.nvim",
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },

  -- == Examples of Overriding Plugins ==

  -- customize alpha options
  {
    "goolord/alpha-nvim",
    opts = function(_, opts)
      -- customize the dashboard header
      opts.section.header.val = {
        " ___________   ____.___   _____   ",
        " \\      \\   \\ /   /|   | /     \\  ",
        " /   |   \\   Y   / |   |/  \\ /  \\ ",
        "/    |    \\     /  |   /    Y    \\",
        "\\____|__  /\\___/   |___\\____|__  /",
        "        \\/                     \\/ ",
        "_______________________      __   ",
        "\\______   \\__    ___/  \\    /  \\  ",
        " |    |  _/ |    |  \\   \\/\\/   /  ",
        " |    |   \\ |    |   \\        /   ",
        " |______  / |____|    \\__/\\  /    ",
        "        \\/                 \\/     ",
      }
      return opts
    end,
  },

  -- You can disable default plugins as follows:
  { "max397574/better-escape.nvim", enabled = false },

  -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom luasnip configuration such as filetype extend or custom snippets
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as custom rules
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
    end,
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    requires = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",

    config = function()
      local harpoon = require "harpoon"

      -- REQUIRED setup call
      harpoon:setup()

      -- Adjusting key mappings based on the new API
      vim.keymap.set("n", "<leader>m", function() harpoon:list():append() end, { desc = "Add file to Harpoon" })
      vim.keymap.set(
        "n",
        "<leader>e",
        function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
        { desc = "Toggle Harpoon menu" }
      )

      -- Navigation within Harpoon list
      vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Go to Mark 1" })
      vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Go to Mark 2" })
      vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Go to Mark 3" })
      vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Go to Mark 4" })

      -- Toggle previous & next buffers stored within the Harpoon list
      vim.keymap.set("n", "<leader>np", function() harpoon:list():prev() end, { desc = "Previous Harpoon Mark" })
      vim.keymap.set("n", "<leader>nn", function() harpoon:list():next() end, { desc = "Next Harpoon Mark" })
    end,
  },
}
