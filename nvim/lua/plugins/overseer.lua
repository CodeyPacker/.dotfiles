return {
  "stevearc/overseer.nvim",
  cmd = { "OverseerRun", "OverseerToggle", "OverseerQuickAction" },
  opts = {
    templates = { "builtin", "npm", "yarn", "pnpm" },
    task_list = {
      bindings = { ["<Esc>"] = "Close" },
      direction = "float",
      width = 0.5,
      height = 0.5,
      max_width = 0.5,
      max_height = 0.5,
    },
  },
  keys = {
    { "<leader>tr", "<cmd>OverseerRun<CR>", desc = "Run task" },
    { "<leader>tl", function() require("overseer").toggle({ direction = "float" }) end, desc = "Task list (float)" },
    {
      "<leader>tR",
      function()
        local ok, overseer = pcall(require, "overseer")
        if not ok or not overseer then
          return
        end
        local tasks = overseer.list_tasks({ recent_first = true, unique = true })
        local task = tasks and tasks[1]
        if not task then
          vim.notify("No tasks to restart", vim.log.levels.WARN, { title = "Overseer" })
          return
        end
        task:restart(true)
      end,
      desc = "Restart last task",
    },
  },
}
