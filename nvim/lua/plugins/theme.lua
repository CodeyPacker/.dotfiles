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

			-- Apply transparency consistently
			local elements = {
				"Normal",
				"NonText",
				"NormalNC",
				"NvimTreeNormal",
				"NvimTreeNormalNC",
				"StatusLineNC",
				"NvimTreeVertSplit",
				"NvimTreeWinSeparator",
				"VertSplit",
				"HarpoonWindow",
				"NormalFloat",
				"FloatBorder",
				"Pmenu",
				"PmenuSel",
				"StatusLine",
				"NvimTreeStatusLine",
				"NvimTreeStatusLineNC",
			}

			for _, element in ipairs(elements) do
				vim.cmd(string.format("highlight %s guibg=NONE ctermbg=NONE", element))
			end

      -- Make line numbers a lighter shade for visibility
      vim.cmd("highlight LineNr guifg=#A5ADCB ctermfg=240")

      -- Set NonText (~ symbols) to a less obtrusive color matching the theme
      vim.cmd("highlight NonText guifg=#494D64 ctermfg=238")

      -- Optional: Set EndOfBuffer to match NonText
      vim.cmd("highlight EndOfBuffer guifg=#494D64 ctermfg=238")
		end,
	},
}
