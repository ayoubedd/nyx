return {
	"saghen/blink.cmp",
	lazy = false,
	dependencies = {
		{ "saghen/blink.compat", version = "*", opts = { impersonate_nvim_cmp = true } },
		"rafamadriz/friendly-snippets",
	},
	version = "1.*",
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		keymap = { preset = "default" },

		appearance = {
			use_nvim_cmp_as_default = false,
			nerd_font_variant = "mono",
		},

		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			providers = {},
		},

		-- experimental auto-brackets support
		completion = {
			keyword = { range = "full" },
			accept = { auto_brackets = { enabled = false } },
			list = { selection = { preselect = false, auto_insert = true } },
			ghost_text = { enabled = true },
		},

		snippets = { preset = "default" },

		-- experimental signature help support
		signature = { enabled = true },
	},
	-- allows extending the enabled_providers array elsewhere in your config
	-- without having to redefine it
	opts_extend = { "sources.completion.enabled_providers" },
}
