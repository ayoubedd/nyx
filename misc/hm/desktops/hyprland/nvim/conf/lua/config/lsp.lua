vim.lsp.config.devenv = {
	cmd = { "devenv", "lsp" },
	filetypes = { "nix" },
	root_markers = { "devenv.nix" },
}

vim.lsp.enable({
	"tsgo",

	"html",
	"cssls",
	"jsonls",
	"svelte",
	"eslint",
	"css_variables",
	"emmet_language_server",

	"emmylua_ls",
	"pyright",
	"rust_analyzer",
	"clangd",
	"gopls",
	-- "devenv",
	-- "denols",
	-- "harper_ls",
	-- "nixd",
})
