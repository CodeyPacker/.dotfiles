return {
  "lke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = { enabled = true },
    explorer = {
      enabled = true,
      win = {
        input = {
          keys = {
            ["<c-v>"] = { "edit_vsplit", mode = { "n", "i" } },
          },
        },
      },
    },
    indent = { enabled = true },
    input = { enabled = true },
    picker = {
      enabled = true,
      win = {
        input = {
          keys = {
            ["<c-v>"] = { "edit_vsplit", mode = { "n", "i" } },
          },
        },
        list = {
          keys = {
          },
        },
      },
      sources = {
        marks = {
          finder = function(opts, ctx)
            local items = require("snacks.picker.source.vim").marks(opts, ctx)
            local ret = {}
            for _, item in ipairs(items) do
              if item.label and item.label:match("^[a-z]$") then
                table.insert(ret, item)
              end
            end
            return ret
          end,
          win = {
            input = {
              keys = {
                ["dd"] = { "mark_delete", mode = { "n", "i" } },
                ["<leader>e"] = { "close", mode = { "n", "i" } },
              },
            },
          },
        },
      },
    },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scratch = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
  config = function(_, opts)
    require("snacks").setup(opts)
    -- Make picker directory paths slightly lighter for readability
    vim.api.nvim_set_hl(0, "SnacksPickerDir", { fg = "#8AADF4" })

  end,
  keys = {
    { "<leader>ff", function() Snacks.picker.files() end,     desc = "Find Files" },
    { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
    { "<leader>fs", function() Snacks.picker.grep() end,      desc = "Find String (grep)" },
    { "<leader>fb", function() Snacks.picker.buffers() end,   desc = "Buffers" },
    { "<leader>b",  function() Snacks.explorer() end,         desc = "Toggle Explorer" },
    { "<leader>nh", function() Snacks.picker.notifications() end, desc = "Notification History" },
    { "<leader>sn", function() Snacks.scratch.open() end, desc = "New scratch" },
    { "<leader>sl", function() Snacks.picker.scratch() end, desc = "Scratch list" },
    {
      "<leader>m",
      function()
        local used = {}
        for _, m in ipairs(vim.fn.getmarklist(0)) do
          local name = m.mark:sub(2, 2)
          if name:match("^[a-z]$") then
            used[name] = true
          end
        end
        local mark = "a"
        for code = string.byte("a"), string.byte("z") do
          local ch = string.char(code)
          if not used[ch] then
            mark = ch
            break
          end
        end
        vim.cmd.normal({ args = { "m" .. mark }, bang = true })
        Snacks.notify(string.format("Set mark '%s'", mark), { title = "Marks" })
      end,
      desc = "Set Mark (auto)",
    },
    {
      "<leader>e",
      function()
        local existing = Snacks.picker.get({ source = "marks" })[1]
        if existing then
          existing:close()
          return
        end
        Snacks.picker.marks({
          global = false,
          ["local"] = true,
        })
      end,
      desc = "Toggle Marks",
    },
    { "<leader>fr", function() Snacks.picker.recent() end,                                  desc = "Recent" },
    { "<leader>fp", function() Snacks.picker.projects() end,                                desc = "Projects" },
    { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
    { "<leader>z",  function() Snacks.zen() end,                                            desc = "Toggle Zen Mode" },
    { "<leader>tt", function() Snacks.terminal() end, desc = "Toggle Terminal", mode = { "n", "t" } },
    { "<leader>tg", function() Snacks.lazygit() end,  desc = "Toggle Lazygit",  mode = { "n", "t" } },
  },
}
