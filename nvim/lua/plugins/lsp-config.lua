local lsp = require("config.lsp")

local ensured_servers = {
  -- Web
  "ts_ls",
  "eslint",
  "jsonls",
  "html",
  "cssls",
  "graphql",
  -- Shell and config
  "lua_ls",
  "bashls",
  "dotls",
  -- Backend and infra
  "gopls",
  "intelephense",
  "sqlls",
  "dockerls",
  "docker_compose_language_service",
}

local servers = {
  lua_ls = {},
  ts_ls = {
    init_options = {
      preferences = {
        disableSuggestions = true,
      },
    },
  },
  eslint = {},
  jsonls = {},
  html = {},
  cssls = {},
  graphql = {},
  bashls = {},
  dotls = {},
  gopls = {},
  intelephense = {},
  sqlls = {},
  dockerls = {},
  docker_compose_language_service = {},
}

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
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
            ensure_installed = ensured_servers,
            automatic_enable = false,
          })
        end,
      },
    },
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

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = lsp.on_attach,
      })

      for server, config in pairs(servers) do
        vim.lsp.config(server, config)
        vim.lsp.enable(server)
      end

      vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show diagnostics for line" })
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
    end,
  },
}
