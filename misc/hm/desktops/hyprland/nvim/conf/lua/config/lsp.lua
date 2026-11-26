-- Only the extra capability: blink.cmp already registered its completion
-- capabilities on "*", and vim.lsp.config merges into that (passing the stock
-- make_client_capabilities() here overwrote blink's).
vim.lsp.config("*", {
	capabilities = {
		workspace = {
			didChangeWatchedFiles = { dynamicRegistration = true },
		},
	},
})

vim.diagnostic.config({
	severity_sort = true,
	-- Inline text comes from tiny-inline-diagnostic.
	virtual_text = false,
	float = { border = "rounded", source = true },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.HINT] = "󰌵",
		},
	},
})

-- Inlay hints wherever the server provides them (toggle: <leader>lh).
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("nyx-lsp-attach", { clear = true }),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client and client:supports_method("textDocument/inlayHint", ev.buf) then
			vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
		end
	end,
})

-- Filetypes the language servers expect but Neovim doesn't detect itself.
local function in_helm_chart(path)
	return vim.fs.root(path, "Chart.yaml") ~= nil
end
vim.filetype.add({
	extension = {
		-- Neovim's default for .tf is TinyFugue ("tf"); tofu_ls wants "terraform".
		tf = "terraform",
		tfvars = "terraform-vars",
	},
	pattern = {
		-- Helm templates and values (helm_ls). Only inside a chart, so other
		-- "templates" folders stay plain yaml.
		[".*/templates/.*%.ya?ml"] = function(path)
			return in_helm_chart(path) and "helm" or nil
		end,
		[".*/templates/.*%.tpl"] = function(path)
			return in_helm_chart(path) and "helm" or nil
		end,
		[".*/values.*%.ya?ml"] = function(path)
			return in_helm_chart(path) and "yaml.helm-values" or nil
		end,
	},
})

vim.lsp.config("tofu_ls", {
	filetypes = { "opentofu", "opentofu-vars", "terraform", "terraform-vars" },
})

-- Schemas from SchemaStore.nvim (GitHub workflows, compose, kustomize, CI
-- configs, package.json, tsconfig, ...). Filled in before_init so the plugin is
-- required only when a server actually starts. yamlls's own store download is
-- off: the plugin's catalog replaces it.
vim.lsp.config("yamlls", {
	settings = {
		yaml = {
			schemaStore = { enable = false, url = "" },
			schemas = {},
		},
	},
	before_init = function(_, config)
		config.settings.yaml.schemas = require("schemastore").yaml.schemas({
			extra = {
				{
					name = "Kubernetes (*.k8s.yaml)",
					description = "Kubernetes manifests",
					fileMatch = "*.k8s.yaml",
					url = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/refs/heads/master/v1.32.9-standalone-strict/all.json",
				},
			},
		})
	end,
})

vim.lsp.config("jsonls", {
	settings = { json = { validate = { enable = true } } },
	before_init = function(_, config)
		config.settings.json.schemas = require("schemastore").json.schemas()
	end,
})

-- NixOS and home-manager option completion/hover from this flake (nixd
-- evaluates it lazily and caches; outside the repo it still knows nixpkgs).
local nyx_flake = vim.fn.expand("~/Projects/Code/me/nyx")
local nyx = string.format('(builtins.getFlake "%s")', nyx_flake)
vim.lsp.config("nixd", {
	settings = {
		nixd = {
			nixpkgs = { expr = nyx .. ".inputs.nixpkgs.legacyPackages.x86_64-linux" },
			options = {
				nixos = { expr = nyx .. ".nixosConfigurations.x1.options" },
				home_manager = {
					expr = nyx .. ".nixosConfigurations.x1.options.home-manager.users.type.getSubOptions []",
				},
			},
		},
	},
})

-- Grammar checking for prose only; on code it flags every comment and
-- identifier. (typos_lsp covers spelling in code.)
vim.lsp.config("harper_ls", {
	filetypes = { "markdown", "gitcommit", "text", "typst", "asciidoc", "rst" },
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
	"qmlls",

	"bashls", -- runs shellcheck itself when it's on PATH
	"docker_language_server", -- Dockerfile + compose
	"marksman", -- markdown links/headings
	"taplo", -- toml
	"typos_lsp",
	"harper_ls",
})
