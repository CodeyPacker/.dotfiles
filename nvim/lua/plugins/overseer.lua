return {
  "stevearc/overseer.nvim",
  cmd = { "OverseerRun", "OverseerToggle", "OverseerQuickAction" },
  opts = {
    templates = { "builtin", "npm", "yarn", "pnpm" },
    task_list = {
      bindings = { ["<Esc>"] = "Close" },
      direction = "float",
      width = 0.8,
      height = 0.8,
      max_width = 0.8,
      max_height = 0.8,
    },
  },
  keys = {
    { "<leader>os", "<cmd>OverseerRun<CR>", desc = "Run task" },
    { "<leader>ol", function() require("overseer").toggle({ direction = "float" }) end, desc = "Task list (float)" },
    {
      "<leader>or",
      function()
        local ok, overseer = pcall(require, "overseer.task_list")
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
