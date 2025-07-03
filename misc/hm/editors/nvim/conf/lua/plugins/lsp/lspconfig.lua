return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		local lspconfig = require("lspconfig")
		local lspui = require("lspconfig.ui.windows")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local capabilities = cmp_nvim_lsp.default_capabilities()

		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type

			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		--LspInfo Borders
		lspui.default_options.border = "single"

		-- Managing language servers individually
		-- pyright
		lspconfig.pyright.setup({
			capabilities = capabilities,
		})

		local json_capabilities = capabilities
		json_capabilities.textDocument.completion.completionItem.snippetSupport = true

		lspconfig.jsonls.setup({
			capabilities = json_capabilities,
			cmd = { "vscode-json-language-server", "--stdio" },
		})

		lspconfig.harper_ls.setup({})

		lspconfig.typos_lsp.setup({
			capabilities = capabilities,
		})

		lspconfig.nixd.setup({
			capabilities = capabilities,
			cmd = { "nixd" },
		})

		lspconfig.eslint.setup({
			capabilities = capabilities,
			filetypes = {
				"javascript",
				"javascriptreact",
				"javascript.jsx",
				"typescript",
				"typescriptreact",
				"typescript.tsx",
				"vue",
				"svelte",
				"astro",
			},
		})

		lspconfig.denols.setup({})

		-- tsserver
		lspconfig.ts_ls.setup({
			single_file_support = false,
			capabilities = capabilities,
			settings = {
				diagnostics = { ignoredCodes = { 6133 } },
			},
		})

		-- rust_analyzer
		lspconfig.rust_analyzer.setup({
			capabilities = capabilities,
			-- Server-specific settings. See `:help lspconfig-setup`
			settings = {
				["rust-analyzer"] = {
					diagnostics = {
						enable = true,
					},
				},
			},
		})

		-- clangd
		lspconfig.clangd.setup({
			capabilities = capabilities,
		})

		-- html
		lspconfig.html.setup({
			capabilities = capabilities,
		})

		-- svelte
		lspconfig.svelte.setup({
			capabilities = capabilities,
		})

		-- configure emmet language server
		local emmet_caps = capabilities
		emmet_caps.textDocument.completion.completionItem.snippetSupport = true

		lspconfig.emmet_ls.setup({
			capabilities = emmet_caps,
			filetypes = {
				"css",
				"eruby",
				"html",
				"javascript",
				"javascriptreact",
				"less",
				"sass",
				"scss",
				"svelte",
				"pug",
				"typescriptreact",
				"vue",
			},
		})

		-- Lua LS
		lspconfig.lua_ls.setup({
			capabilities = capabilities,
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
				},
			},
		})

		-- CSS LS
		lspconfig.cssls.setup({
			capabilities = capabilities,
		})

		-- lspconfig.tailwindcss.setup({
		-- 	capabilities = capabilities,
		-- })
	end,
}
