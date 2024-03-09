return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
		require("toggleterm").setup({
			direction = "float",
			-- Configuration options for floating windows
			float_opts = {
				border = "curved", -- Other options: 'single', 'double', 'shadow', 'curved'...
				winblend = 0,
				highlights = {
					border = "Normal",
					background = "Normal",
				},
			},
		})

		local map = vim.api.nvim_set_keymap
		local opts = { noremap = true, silent = true }
		function _G.toggle_terminal()
			require("toggleterm").toggle()
		end

		-- Normal mode mapping
		vim.api.nvim_set_keymap("n", "<leader>tt", "<cmd>lua toggle_terminal()<CR>", { noremap = true, silent = true })

		-- Terminal mode mapping
		vim.api.nvim_set_keymap("t", "<leader>tt", "<cmd>lua toggle_terminal()<CR>", { noremap = true, silent = true })
	end,
}
