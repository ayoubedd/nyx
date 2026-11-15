vim.lsp.config("*", {
	capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), {
		workspace = {
			didChangeWatchedFiles = { dynamicRegistration = true },
		},
	}),
})

vim.lsp.config("yamlls", {
	settings = {
		yaml = {
			schemas = {
				["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
				["../path/relative/to/file.yml"] = "/.github/workflows/*",
				["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/refs/heads/master/v1.32.9-standalone-strict/all.json"] = "/*.k8s.yaml",
			},
		},
	},
})

vim.lsp.enable({
	"tsc",

	"html",
	"cssls",
	"jsonls",
	"svelte",
	"eslint",
	"css_variables",
	-- "emmet_language_server",

	"emmylua_ls",
	"pyright",
	"rust_analyzer",
	"clangd",
	"gopls",
	"tofu_ls",
	"nixd",
	"yamlls",
	"helm_ls",
})
