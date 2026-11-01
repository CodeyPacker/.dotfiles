return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("harpoon"):setup({
      default = {
        -- Show paths relative to the file's repo root. On Windows harpoon
        -- stores absolute paths because cwd uses backslashes and buffer
        -- names don't.
        display = function(item)
          local cwd = vim.fs.normalize(vim.uv.cwd())
          local path = vim.fs.normalize(item.value)
          if not path:match("^%a:/") and not path:match("^/") then
            path = cwd .. "/" .. path
          end
          local root = vim.fs.root(path, ".git") or cwd
          local prefix = vim.fs.normalize(root) .. "/"
          if path:sub(1, #prefix):lower() == prefix:lower() then
            return path:sub(#prefix + 1)
          end
          return path
        end,
      },
    })

    -- Highlight the filename (last path segment) in the marks menu.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "harpoon",
      callback = function()
        vim.cmd([[syntax match HarpoonFilename "[^/]\+$"]])
      end,
    })
  end,
  keys = {
    {
      "<leader>m",
      function()
        require("harpoon"):list():add()
      end,
      desc = "Mark File",
    },
    {
      "<leader>e",
      function()
        local harpoon = require("harpoon")
        -- Use the same rounded panel border as other floating menus.
        harpoon.ui:toggle_quick_menu(harpoon:list(), { border = "rounded" })
      end,
      desc = "Show Marked Files",
    },
  },
}
