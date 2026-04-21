return {
	{
		"catppuccin/nvim",
		lazy = false,
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				term_colors = true,
				flavour = "macchiato", -- Use the macchiato flavor
				styles = {
					comments = { "italic" },
					conditionals = { "italic" },
					loops = {},
					functions = {},
					keywords = { "bold" },
					strings = {},
					variables = {},
					numbers = {},
					booleans = {},
					properties = {},
					types = { "italic" },
				},
				color_overrides = {
					macchiato = {
						base = "#24273A", -- Slightly lighter for macchiato
						mantle = "#1E2030",
						crust = "#181926",
					},
				},
			})

			vim.cmd.colorscheme("catppuccin")

			local elements = {
				"Normal",
				"NonText",
				"NormalNC",
				"StatusLineNC",
				"VertSplit",
				"HarpoonWindow",
				"NormalFloat",
				"FloatBorder",
				"Pmenu",
				"PmenuSel",
				"StatusLine",
        "EndOfBuffer",
        "LineNr",
			}

			for _, element in ipairs(elements) do
				vim.api.nvim_set_hl(0, element, { bg = "NONE", ctermbg = "NONE" })
			end

      vim.api.nvim_set_hl(0, "LineNr", { fg = "#A5ADCB", bg = "NONE", ctermfg = 240, ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "NonText", { fg = "#494D64", bg = "NONE", ctermfg = 238, ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = "#494D64", bg = "NONE", ctermfg = 238, ctermbg = "NONE" })
		end,
	},
}
