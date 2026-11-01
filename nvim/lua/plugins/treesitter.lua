-- nvim-treesitter's main branch only installs parsers. Neovim itself does
-- the highlighting, started per buffer below. The plugin can't lazy-load.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    -- Building parsers needs the tree-sitter CLI (Brewfile: tree-sitter-cli).
    if vim.fn.executable("tree-sitter") == 1 then
      require("nvim-treesitter").install({ "c_sharp", "sql" })
    end
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        -- Fails quietly for filetypes with no installed parser.
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
