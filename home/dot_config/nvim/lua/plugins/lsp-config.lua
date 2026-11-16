local lsp = require("config.lsp")

local servers = require("config.lsp_servers")
local ensured_servers = vim.tbl_keys(servers)
table.sort(ensured_servers)

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
