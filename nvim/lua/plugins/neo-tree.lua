return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      follow_current_file = true,
      group_empty_dirs = true,
      hijack_netrw_behavior = "open_default",
      use_libuv_file_watcher = true,
      bind_to_cwd = true,
      cwd_target = {
        sidebar = "tab", -- or "global"
        current = "window",
      },
      filtered_items = {
        hide_dotfiles = false,
      },
    },
  },
}
