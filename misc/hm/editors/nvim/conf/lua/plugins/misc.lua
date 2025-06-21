return {
	"tpope/vim-sleuth", -- Automatically set the 'shiftwidth' and 'expandtab' options based on the current file
	{
		"LunarVim/bigfile.nvim", -- Disables certain plugins/features on big files
		config = function()
			-- default config
			require("bigfile").setup({
				filesize = 2, -- size of the file in MiB, the plugin round file sizes to the closest MiB
				pattern = { "*" }, -- autocmd pattern or function see <### Overriding the detection of big files>
				features = { -- features to disable
					"indent_blankline",
					"illuminate",
					"lsp",
					"treesitter",
					"syntax",
					"matchparen",
					"vimopts",
					"filetype",
				},
			})
		end,
	},
}
