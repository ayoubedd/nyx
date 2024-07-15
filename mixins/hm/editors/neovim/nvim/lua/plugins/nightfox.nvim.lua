return {
	"EdenEast/nightfox.nvim",
	lazy = false,
	priority = 1000,
	opts = {
		options = {
			styles = { -- Style to be applied to different syntax groups
				comments = "italic", -- Value is any valid attr-list value `:help attr-list`
				conditionals = "NONE",
				constants = "bold",
				functions = "italic",
				keywords = "NONE",
				numbers = "NONE",
				operators = "NONE",
				strings = "NONE",
				types = "NONE",
				variables = "NONE",
			},
		},
	},
	config = function(_, opts)
		require("nightfox").setup(opts)
		vim.cmd([[colorscheme carbonfox]])
	end,
}
