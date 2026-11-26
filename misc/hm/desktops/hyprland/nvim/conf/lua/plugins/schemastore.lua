-- JSON/YAML schema catalog for jsonls and yamlls (wired up in config/lsp.lua;
-- required from their before_init, so it loads when one of them starts).
return {
	"b0o/SchemaStore.nvim",
	lazy = true,
	version = false,
}
