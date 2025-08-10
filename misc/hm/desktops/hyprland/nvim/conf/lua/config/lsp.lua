vim.lsp.config.tsserver_ls = {
	init_options = { hostInfo = "neovim" },
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
	single_file_support = false,
	settings = {
		typescript = {
			inlayHints = {
				includeInlayParameterNameHints = "all",
				includeInlayParameterNameHintsWhenArgumentMatchesName = false,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayVariableTypeHints = true,
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayEnumMemberValueHints = true,
			},
		},
		javascript = {
			inlayHints = {
				includeInlayParameterNameHints = "all",
				includeInlayParameterNameHintsWhenArgumentMatchesName = false,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayVariableTypeHints = true,
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayEnumMemberValueHints = true,
			},
		},
	},
}

local mod_cache = nil

---@param fname string
---@return string?
local function get_root(fname)
	if mod_cache and fname:sub(1, #mod_cache) == mod_cache then
		local clients = vim.lsp.get_clients({ name = "gopls" })
		if #clients > 0 then
			return clients[#clients].config.root_dir
		end
	end
	return vim.fs.root(fname, "go.work") or vim.fs.root(fname, "go.mod") or vim.fs.root(fname, ".git")
end

vim.lsp.config.gopls = {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		-- see: https://github.com/neovim/nvim-lspconfig/issues/804
		if mod_cache then
			on_dir(get_root(fname))
			return
		end
		local cmd = { "go", "env", "GOMODCACHE" }
		vim.system(cmd, { text = true }, function(output)
			if output.code == 0 then
				if output.stdout then
					mod_cache = vim.trim(output.stdout)
				end
				on_dir(get_root(fname))
			else
				vim.schedule(function()
					vim.notify(("[gopls] cmd failed with code %d: %s\n%s"):format(output.code, cmd, output.stderr))
				end)
			end
		end)
	end,
}

vim.lsp.config.emet_ls = {
	cmd = { "emmet-ls", "--stdio" },
	filetypes = {
		"astro",
		"css",
		"eruby",
		"html",
		"htmlangular",
		"htmldjango",
		"javascriptreact",
		"less",
		"pug",
		"sass",
		"scss",
		"svelte",
		"templ",
		"typescriptreact",
		"vue",
	},
	root_markers = { ".git" },
}

vim.lsp.config.denols = {
	cmd = { "deno", "lsp" },
	cmd_env = { NO_COLOR = true },
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
	root_markers = { "deno.json", "deno.jsonc", ".git" },
	settings = {
		deno = {
			enable = true,
			suggest = {
				imports = {
					hosts = {
						["https://deno.land"] = true,
					},
				},
			},
		},
	},
}

vim.lsp.config.css_ls = {
	cmd = { "vscode-css-language-server", "--stdio" },
	filetypes = { "css", "scss", "less" },
	root_markers = { "package.json", ".git" },
	init_options = { provideFormatter = true },
	single_file_support = true,
	settings = {
		cssVariables = {
			lookupFiles = { "**/*.less", "**/*.scss", "**/*.sass", "**/*.css" },
		},
		css = { validate = true },
		scss = { validate = true },
		less = { validate = true },
	},

	capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), {
		textDocument = {
			completion = {
				completionItem = {
					-- this causes an error using native lsp
					snippetSupport = true, -- set to false if you don't use blink
				},
			},
		},
	}),
}

vim.lsp.config.eslint = {
	cmd = { "vscode-eslint-language-server", "--stdio" },

	root_markers = {
		".eslintrc",
		".eslintrc.js",
		".eslintrc.cjs",
		".eslintrc.yaml",
		".eslintrc.yml",
		".eslintrc.json",
		"eslint.config.js",
		"eslint.config.mjs",
		"eslint.config.cjs",
		"eslint.config.ts",
		"eslint.config.mts",
		"eslint.config.cts",
	},
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
		"htmlangular",
	},
	settings = {
		validate = "on",
		packageManager = nil,
		useESLintClass = false,
		experimental = {
			useFlatConfig = false,
		},
		codeActionOnSave = {
			enable = false,
			mode = "all",
		},
		format = true,
		quiet = false,
		onIgnoredFiles = "off",
		rulesCustomizations = {},
		run = "onType",
		problems = {
			shortenToSingleLine = false,
		},
		-- nodePath configures the directory in which the eslint server should start its node_modules resolution.
		-- This path is relative to the workspace folder (root dir) of the server instance.
		nodePath = "",
		-- use the workspace folder location or the file location (if no workspace folder is open) as the working directory
		workingDirectory = { mode = "location" },
		codeAction = {
			disableRuleComment = {
				enable = true,
				location = "separateLine",
			},
			showDocumentation = {
				enable = true,
			},
		},
	},
}

vim.lsp.config.nixd = {
	cmd = { "nixd" },
	filetypes = { "nix" },
	root_markers = { "flake.nix", "git" },
}

vim.lsp.config.html = {
	cmd = { "vscode-html-language-server", "--stdio" },
	filetypes = { "html", "templ" },
	root_markers = { "package.json", ".git" },
	settings = {},
	init_options = {
		provideFormatter = true,
		embeddedLanguages = { css = true, javascript = true },
		configurationSection = { "html", "css", "javascript" },
	},
}

vim.lsp.config.jsonls = {
	cmd = { "vscode-json-language-server", "--stdio" },
	filetypes = { "json", "jsonc" },
	init_options = {
		provideFormatter = true,
	},
	root_markers = { ".git" },
}

vim.lsp.config.rust_analyzer = {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = {
		"Cargo.toml",
		"Cargo.lock",
	},
	settings = {
		["rust-analyzer"] = {
			diagnostics = {
				enable = false,
			},
		},
	},
}

vim.lsp.config.clangd = {
	cmd = { "clangd" },
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
	root_markers = {
		".clangd",
		".clang-tidy",
		".clang-format",
		"compile_commands.json",
		"compile_flags.txt",
		"configure.ac", -- AutoTools
		".git",
	},
	capabilities = {
		textDocument = {
			completion = {
				editsNearCursor = true,
			},
		},
		offsetEncoding = { "utf-8", "utf-16" },
	},
}

vim.lsp.config.lua_ls = {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
	settings = {
		Lua = {
			runtime = {
				-- Specify LuaJIT for Neovim
				version = "LuaJIT",
				-- Include Neovim runtime files
				path = vim.split(package.path, ";"),
			},
			diagnostics = {
				-- Recognize `vim` as a global
				globals = { "vim" },
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			hint = {
				enable = true,
				arrayIndex = "Enable",
				await = true,
				paramName = "All",
				paramType = true,
				semicolon = "Disable",
				setType = true,
			},
			telemetry = {
				enable = false,
			},
		},
	},
}

vim.lsp.config.harper_ls = {
	cmd = { "harper-ls", "--stdio" },
	filetypes = {
		"nix",
		"c",
		"cpp",
		"cs",
		"gitcommit",
		"go",
		"html",
		"java",
		"javascript",
		"lua",
		"markdown",
		"nix",
		"python",
		"ruby",
		"rust",
		"swift",
		"toml",
		"typescript",
		"typescriptreact",
		"haskell",
		"cmake",
		"typst",
		"php",
		"dart",
	},
	root_markers = { ".git" },
	-- root_dir = function(fname)
	-- 	return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
	-- end,
	single_file_support = true,
	settings = {
		["harper-ls"] = {
			-- userDictPath = "",
			-- fileDictPath = "",
			linters = {
				SpellCheck = true,
				SpelledNumbers = false,
				AnA = true,
				SentenceCapitalization = true,
				UnclosedQuotes = true,
				WrongQuotes = false,
				LongSentences = true,
				RepeatedWords = true,
				Spaces = true,
				Matcher = true,
				CorrectNumberSuffix = true,
			},
			codeActions = {
				ForceStable = false,
			},
			markdown = {
				IgnoreLinkTitle = false,
			},
			diagnosticSeverity = "hint",
			isolateEnglish = false,
			dialect = "American",
			maxFileLength = 120000,
		},
	},
}

vim.lsp.config.svelte = {
	cmd = { "svelteserver", "--stdio" },
	filetypes = { "svelte" },
	root_dir = function(bufnr, on_dir)
		local root_files = { "package.json", ".git" }
		local fname = vim.api.nvim_buf_get_name(bufnr)
		-- Svelte LSP only supports file:// schema. https://github.com/sveltejs/language-tools/issues/2777
		if vim.uv.fs_stat(fname) ~= nil then
			on_dir(vim.fs.dirname(vim.fs.find(root_files, { path = fname, upward = true })[1]))
		end
	end,
	on_attach = function(client, bufnr)
		vim.api.nvim_buf_create_user_command(bufnr, "LspMigrateToSvelte5", function()
			client:exec_cmd({
				command = "migrate_to_svelte_5",
				arguments = { vim.uri_from_bufnr(bufnr) },
			})
		end, { desc = "Migrate Component to Svelte 5 Syntax" })
	end,
}

vim.lsp.config.yamlls = {
	cmd = { "yaml-language-server", "--stdio" },
	filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values" },
	root_markers = { ".git" },
	settings = {
		yaml = {
			schemas = {
				["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*.yaml",
				["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/refs/heads/master/v1.32.2-standalone-strict/all.json"] = "/*.k8s.yaml",
			},
		},
		-- https://github.com/redhat-developer/vscode-redhat-telemetry#how-to-disable-telemetry-reporting
		redhat = { telemetry = { enabled = false } },
	},
}

vim.lsp.config.pyright = {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"Pipfile",
		"pyrightconfig.json",
	},
}

vim.lsp.enable({
	"tsserver_ls",
	"css_ls",
	"lua_ls",
	"pyright",
	"eslint",
	"rust_analyzer",
	"clangd",
	"denols",
	"emet_ls",
	"gopls",
	"nixd",
	"html",
	"jsonls",
	"harper_ls",
	"svelte",
})
