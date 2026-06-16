return {
	"FylerOrg/fyler.nvim",
	opts = {
		-- Whether to skip confirmation for "simple" mutations.
		-- A simple mutation has at most:
		-- - 1 copy operation
		-- - 1 delete operation
		-- - 1 move operation
		-- - 5 create operations
		auto_confirm_simple_mutation = false,
		-- Restricts cursor from moving outside editable region
		bound_cursor = true,
		-- Follow current file
		follow_current_file = true,
		-- Extensions
		extensions = { git = { enabled = true, inline = false } },
		-- Event hooks
		hooks = {},
		integrations = { icon = "nvim_web_devicons" },
		-- Buffer kind to use globally.
		kind = "replace",
		-- Per-kind buffer configuration.
		kind_presets = {
			floating = {
				-- Border style (see: :h winborder)
				border = "single",
				-- Size of buffer:
				-- - string with '%' for relative (e.g. '70%')
				-- - number for absolute
				height = "80%",
				mappings = { n = { ["<CR>"] = { action = "select", args = { close = true } } } },
				width = "60%",
				-- Horizontal alignment: 'start' | 'center' | 'end'
				col = "center",
				-- Vertical alignment: 'start' | 'center' | 'end'
				row = "center",
			},
			replace = {
				mappings = { n = { ["<CR>"] = { action = "select", args = { close = true } } } },
			},
			split_above = { height = "50%" },
			split_above_all = { height = "50%" },
			split_below = { height = "50%" },
			split_below_all = { height = "50%" },
			split_left = { width = "20%" },
			split_left_most = { width = "20%" },
			split_right = { width = "20%" },
			split_right_most = { width = "20%" },
		},
		mappings = {
			n = {
				["-"] = { action = "visit", args = { parent = true } },
				["."] = { action = "visit", args = { cursor = true } },
				["<BS>"] = { action = "shrink", args = { parent = true } },
				["<C-r>"] = { action = "refresh" },
				["<C-s>"] = { action = "select", args = { split = true } },
				["<C-t>"] = { action = "select", args = { tabedit = true } },
				["<C-v>"] = { action = "select", args = { vsplit = true } },
				["<CR>"] = { action = "select" },
				["="] = { action = "visit" },
				["g."] = { action = "toggle_ui", args = { "hidden_items" } },
				["gi"] = { action = "toggle_ui", args = { "indent_guides" } },
				["q"] = { action = "close" },
			},
		},
		-- UI options
		ui = {
			-- Whether to draw indent guides at each depth level.
			hidden_items = {
				-- Toggleable pre-defined switches (e.g. 'dotfiles' to hide files starting with a dot).
				switches = { "dotfiles" },
				-- Toggleable patterns (Lua patterns matched against the full path).
				patterns = {},
				-- Always visible items matching these patterns, even if they would normally be hidden.
				always_visible = {},
				-- Always hide items matching these patterns, even if they would normally be visible.
				always_hidden = {},
			},
			indent_guides = false,
		},
	},
	config = function(_, opts)
    local fyler = require('fyler');
    fyler.setup(opts);
		vim.keymap.set("n", "<leader>e", function()
			fyler.open({ kind = "split_right_most" })
		end, { desc = "Fyler.nvim - Open" })
	end,
}
