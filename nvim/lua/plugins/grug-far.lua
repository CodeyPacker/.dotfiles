return {
  "MagicDuck/grug-far.nvim",
  cmd = "GrugFar",
  config = function()
    local find_replace = require("config.find_replace")
    find_replace.register_preserve_case()
    find_replace.setup_file_rows()
    require("grug-far").setup({
      windowCreationCommand = "lua require('config.find_replace').float()",
      -- Results open in the editor window behind the float.
      openTargetWindow = { preferredLocation = "prev" },
      enabledReplacementInterpreters = { "default", "lua", "vimscript", "preserve-case" },
      keymaps = { gotoLocation = false },
      -- Quiet chrome: no help bar, icon-only inputs, one line per result.
      helpLine = { enabled = false },
      showCompactInputs = true,
      showEngineInfo = false,
      showStatusIcon = false,
      wrap = false,
      folding = { foldcolumn = "0" },
      resultLocation = { showNumberLabel = false },
    })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "grug-far",
      callback = function(args)
        find_replace.setup_buffer(args.buf)
      end,
    })
  end,
  keys = {
    -- WezTerm sends Cmd+Shift+F/H as Alt+Shift+F/H, which also survives tmux.
    { "<M-F>", function() require("config.find_replace").open("search") end, mode = { "n", "x" }, desc = "Find in Files" },
    { "<M-H>", function() require("config.find_replace").open("replacement") end, mode = { "n", "x" }, desc = "Replace in Files" },
  },
}
