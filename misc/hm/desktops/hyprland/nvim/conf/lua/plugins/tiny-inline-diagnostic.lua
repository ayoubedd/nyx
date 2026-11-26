return {
	-- {
	-- 	"MysticalDevil/inlay-hints.nvim",
	-- 	event = "LspAttach",
	-- 	dependencies = { "neovim/nvim-lspconfig" },
	-- 	config = function()
	-- 		require("inlay-hints").setup()
	-- 	end,
	-- },
	{

		"rachartier/tiny-inline-diagnostic.nvim",
		event = "LspAttach", -- Or `LspAttach`
		priority = 1000, -- needs to be loaded in first
		config = function()
			-- (virtual_text = false and the rest: config/lsp.lua)
			require("tiny-inline-diagnostic").setup({
				preset = "minimal",
			})
		end,
	},
}
