return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "eslint",
          "lua_ls",
          "ts_ls",
          "jsonls",
          "html",
          "cssls",
          "dotls",
          "gopls",
          -- "marksman",
          -- "ts_ls",
          "graphql",
          "intelephense",
          -- "pylsp",
          -- "rust_analyzer",
          "sqlls",
          -- "vuels",
          "dockerls",
          "docker_compose_language_service",
          "bashls",
        },
        automatic_enable = false,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.diagnostic.config({
        virtual_text = {
          source = "if_many",
        },
        float = {
          source = "always",
          border = "rounded",
        },
        severity_sort = true,
      })

      local servers = {
        lua_ls = {},
        ts_ls = {
          init_options = {
            preferences = {
              disableSuggestions = true,
            },
          },
        },
        graphql = {},
        eslint = {},
        jsonls = {},
        html = {},
        cssls = {},
        dotls = {},
        gopls = {},
        intelephense = {},
        sqlls = {},
        dockerls = {},
        docker_compose_language_service = {},
        bashls = {},
      }

      for server, config in pairs(servers) do
        vim.lsp.config(server, config)
        vim.lsp.enable(server)
      end

      vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show diagnostics for line" })
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
    end,
  },
}
