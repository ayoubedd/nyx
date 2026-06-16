return {
	"anuvyklack/windows.nvim",
  enabled = false,
	dependencies = {
		"anuvyklack/middleclass",
	},
	config = function()
    local windows = require('windows');

		vim.o.winwidth = 5
		vim.o.winminwidth = 5
		vim.o.equalalways = false

		windows.setup({
			ignore = {
        buftype = { "fyler_finder" },
        filetype = { "fyler_finder" },
      },
		})
	end,
}
