return {
	"lewis6991/hover.nvim",
	config = function()
		require("hover").config({
			providers = {
				"hover.providers.lsp",
				"hover.providers.dap",
				"hover.providers.diagnostic",
				"hover.providers.man",
				"hover.providers.dictionary",
				-- Optional, disabled by default:
				-- 'hover.providers.gh',
				-- 'hover.providers.gh_user',
				-- 'hover.providers.jira',
				-- 'hover.providers.fold_preview',
				-- 'hover.providers.highlight',
			},
			preview_opts = {
				border = "single",
			},
			-- Whether the contents of a currently open hover window should be moved
			-- to a :h preview-window when pressing the hover keymap.
			preview_window = false,
			title = true,
			mouse_providers = {
				"hover.providers.lsp",
			},
			mouse_delay = 1000,
		})

		-- Setup keymaps
		vim.keymap.set("n", "K", require("hover").hover, { desc = "hover.nvim" })
		vim.keymap.set("n", "gK", require("hover").hover_select, { desc = "hover.nvim (select)" })
		vim.keymap.set("n", "<C-p>", function()
			require("hover").hover_switch("previous")
		end, { desc = "hover.nvim (previous source)" })
		vim.keymap.set("n", "<C-n>", function()
			require("hover").hover_switch("next")
		end, { desc = "hover.nvim (next source)" })

		-- Mouse support
		vim.o.mousemoveevent = false
	end,
}
