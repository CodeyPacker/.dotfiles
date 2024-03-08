return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    requires = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",

    config = function()
        local harpoon = require("harpoon")

        -- REQUIRED setup call
        harpoon:setup()

        -- Adjusting key mappings based on the new API
        vim.keymap.set("n", "<leader>m", function() harpoon:list():append() end, {desc = "Add file to Harpoon"})
        vim.keymap.set("n", "<leader>e", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, {desc = "Toggle Harpoon menu"})

        -- Navigation within Harpoon list
        vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, {desc = "Go to Mark 1"})
        vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, {desc = "Go to Mark 2"})
        vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, {desc = "Go to Mark 3"})
        vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, {desc = "Go to Mark 4"})

        -- Toggle previous & next buffers stored within the Harpoon list
        vim.keymap.set("n", "<leader>np", function() harpoon:list():prev() end, {desc = "Previous Harpoon Mark"})
        vim.keymap.set("n", "<leader>nn", function() harpoon:list():next() end, {desc = "Next Harpoon Mark"})
    end,
}
