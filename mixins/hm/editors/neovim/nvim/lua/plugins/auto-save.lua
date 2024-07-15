return {
	"Pocco81/auto-save.nvim", -- Automatically save your changes on mode change
	config = function()
		require("auto-save").setup()
	end,
}
