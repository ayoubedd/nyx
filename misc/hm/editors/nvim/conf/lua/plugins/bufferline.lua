return {
	"akinsho/bufferline.nvim",
	requires = "nvim-tree/nvim-web-devicons",
	config = function()
		require("bufferline").setup({
			options = {
				always_show_bufferline = false,
				offsets = {
					{
						filetype = "NvimTree",
						text = "Explorer",
						separator = false,
					},
					{
						filetype = "neo-tree",
						text = "Explorer",
						separator = false,
					},
				},
				indicator = {
					style = "icon",
				},
			},
		})
	end,
}
