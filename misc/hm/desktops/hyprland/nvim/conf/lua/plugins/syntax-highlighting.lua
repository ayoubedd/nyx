return {
	{
		"nvim-treesitter/nvim-treesitter",
		version = false, -- Use the latest commits
		build = ":TSUpdate",
		lazy = false, -- Tree-sitter must load immediately at startup
		config = function()
			require("nvim-treesitter").setup({
				ensure_installed = {
					"svelte",
					"nix",
					"html",
					"css",
					"javascript",
					"typescript",
					"lua",
					"markdown",
					"c",
					"vim",
					"vimdoc",
					"json",
					"zig",
				},
				auto_install = true,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
			})
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					-- 1. BAIL OUT if the filetype is a known UI, explorer, or terminal plugin
					local ignored_filetypes = {
						oil = true,
						["neo-tree"] = true,
						NvimTree = true,
						beacon = true,
						notify = true,
						lazy = true,
						blink = true,
						kitty = true,
					}
					if ignored_filetypes[args.match] then
						return
					end

					-- 2. BAIL OUT if it's a special utility buffer type (terminal, prompt, quickfix, nofile)
					local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
					if buftype ~= "" then
						return
					end

					-- 3. BAIL OUT if the buffer has no real file path associated with it
					local bufname = vim.api.nvim_buf_get_name(args.buf)
					if bufname == "" then
						return
					end

					-- 4. Only start tree-sitter if a valid text parser exists for the language
					local lang = vim.treesitter.language.get_lang(args.match)
					if lang and pcall(vim.treesitter.get_parser, args.buf, lang) then
						-- vim.treesitter.start(args.buf, lang)
						pcall(vim.treesitter.start, args.buf, lang)
					end
				end,
			})
		end,
	},
	{
		"RRethy/vim-illuminate", -- Highlight all instances of the word under the cursor
		config = function()
			-- default configuration
			require("illuminate").configure({
				-- providers: provider used to get references in the buffer, ordered by priority
				providers = {
					"lsp",
					"treesitter",
					"regex",
				},
				-- delay: delay in milliseconds
				delay = 200,
				-- filetype_overrides: filetype specific overrides.
				-- The keys are strings to represent the filetype while the values are tables that
				-- supports the same keys passed to .configure except for filetypes_denylist and filetypes_allowlist
				filetype_overrides = {},
				-- filetypes_denylist: filetypes to not illuminate, this overrides filetypes_allowlist
				filetypes_denylist = {
					"NvimTree",
					"dirbuf",
					"dirvish",
					"fugitive",
					"alpha",
					"toggleterm",
				},
				-- filetypes_allowlist: filetypes to illuminate, this is overridden by filetypes_denylist
				-- You must set filetypes_denylist = {} to override the defaults to allow filetypes_allowlist to take effect
				filetypes_allowlist = {},
				-- modes_denylist: modes to not illuminate, this overrides modes_allowlist
				-- See `:help mode()` for possible values
				modes_denylist = {},
				-- modes_allowlist: modes to illuminate, this is overridden by modes_denylist
				-- See `:help mode()` for possible values
				modes_allowlist = { "n" },
				-- providers_regex_syntax_denylist: syntax to not illuminate, this overrides providers_regex_syntax_allowlist
				-- Only applies to the 'regex' provider
				-- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
				providers_regex_syntax_denylist = {},
				-- providers_regex_syntax_allowlist: syntax to illuminate, this is overridden by providers_regex_syntax_denylist
				-- Only applies to the 'regex' provider
				-- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
				providers_regex_syntax_allowlist = {},
				-- under_cursor: whether or not to illuminate under the cursor
				under_cursor = true,
				-- large_file_cutoff: number of lines at which to use large_file_config
				-- The `under_cursor` option is disabled when this cutoff is hit
				large_file_cutoff = nil,
				-- large_file_config: config to use for large files (based on large_file_cutoff).
				-- Supports the same keys passed to .configure
				-- If nil, vim-illuminate will be disabled for large files.
				large_file_overrides = nil,
				-- min_count_to_highlight: minimum number of matches required to perform highlighting
				min_count_to_highlight = 1,
				-- should_enable: a callback that overrides all other settings to
				-- enable/disable illumination. This will be called a lot so don't do
				-- anything expensive in it.
				should_enable = function(bufnr)
					return true
				end,
				-- case_insensitive_regex: sets regex case sensitivity
				case_insensitive_regex = false,
			})
		end,
	},
	{
		"brenoprata10/nvim-highlight-colors",
		config = function()
			require("nvim-highlight-colors").setup({
				---Render style
				---@usage 'background'|'foreground'|'virtual'
				render = "virtual",

				---Set virtual symbol (requires render to be set to 'virtual')
				virtual_symbol = "■",

				---Highlight named colors, e.g. 'green'
				enable_named_colors = true,

				---Highlight tailwind colors, e.g. 'bg-blue-500'
				enable_tailwind = true,

				---Set custom colors
				---Label must be properly escaped with '%' to adhere to `string.gmatch`
				--- :help string.gmatch
				custom_colors = {
					{ label = "%-%-theme%-primary%-color", color = "#0f1219" },
					{ label = "%-%-theme%-secondary%-color", color = "#5a5d64" },
				},
			})
		end,
	},
}
