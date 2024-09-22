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
          "tsserver",
          "jsonls",
          "html",
          "cssls",
          "dotls",
          "gopls",
          "marksman",
          "eslint",
          "ts_ls",
          "graphql",
          "intelephense",
          "pylsp",
          "rust_analyzer",
          "sqlls",
          "vuels",
          "dockerls",
          "docker_compose_language_service",
          "bashls",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({})
      lspconfig.tsserver.setup({
        init_options = {
          preferences = {
            disableSuggestions = true,
          },
        },
      })
      lspconfig.ts_ls.setup({
        init_options = {
          preferences = {
            disableSuggestions = true,
          },
        },
      })
      lspconfig.graphql.setup({})
      lspconfig.eslint.setup({})
      lspconfig.jsonls.setup({})
      lspconfig.html.setup({})
      lspconfig.cssls.setup({})
      lspconfig.dotls.setup({})
      lspconfig.gopls.setup({})
      lspconfig.marksman.setup({})
      lspconfig.intelephense.setup({})
      lspconfig.pylsp.setup({})
      lspconfig.sqlls.setup({})
      lspconfig.rust_analyzer.setup({})
      lspconfig.vuels.setup({})
      lspconfig.dockerls.setup({})
      lspconfig.docker_compose_language_service.setup({})
      lspconfig.bashls.setup({})
      lspconfig.eslint.setup({})

      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
    end,
  },
}
