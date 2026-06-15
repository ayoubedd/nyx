return {
	{
		"saghen/blink.compat",
		-- use v2.* for blink.cmp v1.*
		version = "2.*",
		-- lazy.nvim will automatically load the plugin when it's required by blink.cmp
		lazy = true,
		-- make sure to set opts so that lazy.nvim calls blink.compat's setup
		opts = {
			impersonate_nvim_cmp = true,
		},
	},
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
