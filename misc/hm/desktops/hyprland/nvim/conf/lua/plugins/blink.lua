return {
	{
		"saghen/blink.cmp",
		version = "1.*",
		lazy = false,
		dependencies = {
			"rafamadriz/friendly-snippets",
		},
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = { preset = "default" },

			appearance = {
				use_nvim_cmp_as_default = false,
				nerd_font_variant = "mono",
			},

			sources = {
				default = { "lazydev", "lsp", "path", "snippets", "buffer" },
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						-- make lazydev completions top priority (see `:h blink.cmp`)
						score_offset = 100,
					},
				},
			},

			-- experimental auto-brackets support
			completion = {
				keyword = { range = "prefix" },
				accept = { auto_brackets = { enabled = false } },
				list = { selection = { preselect = false, auto_insert = true } },
				ghost_text = { enabled = true },
				documentation = { auto_show = true, auto_show_delay_ms = 500 },
			},

			snippets = { preset = "default" },

			-- experimental signature help support
			signature = { enabled = true },
		},
		-- allows extending the enabled_providers array elsewhere in your config
		-- without having to redefine it
		opts_extend = { "sources.completion.enabled_providers" },
	},
}
