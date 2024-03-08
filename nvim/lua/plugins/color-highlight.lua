return {
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({
				-- Leaving it empty applies colorizer to all file types
			})
		end,
	},
}
