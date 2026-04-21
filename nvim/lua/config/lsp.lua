local M = {}

function M.format_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/formatting" })

  if #clients == 0 then
    vim.notify("No formatter available", vim.log.levels.WARN, { title = "LSP" })
    return
  end

  local has_eslint = false
  for _, client in ipairs(clients) do
    if client.name == "eslint" then
      has_eslint = true
      break
    end
  end

  vim.lsp.buf.format({
    async = true,
    filter = function(client)
      if has_eslint then
        return client.name == "eslint"
      end

      return client:supports_method("textDocument/formatting")
    end,
  })
end

function M.on_attach(args)
  local bufnr = args.buf
  local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
  end

  map("K", vim.lsp.buf.hover, "Hover")
  map("gd", vim.lsp.buf.definition, "Go to Definition")
  map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
end

return M
