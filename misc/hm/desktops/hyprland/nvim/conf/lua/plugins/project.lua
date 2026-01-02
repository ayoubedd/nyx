return {
	"DrKJeff16/project.nvim", -- Changes PWD to the root of the project
	config = function()
		-- vim.g.project_lsp_nowarn = 1
		require("project").setup({
			-- Manual mode doesn't automatically change your root directory, so you have
			-- the option to manually do so using `:ProjectRoot` command.
			manual_mode = false,

			-- Methods of detecting the root directory. **"lsp"** uses the native neovim
			-- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
			-- order matters: if one is not detected, the other is used as fallback. You
			-- can also delete or rearangne the detection methods.
			use_lsp = true,

			-- All the patterns used to detect root dir, when **"pattern"** is in
			-- detection_methods
			patterns = {
				"_darcs",
				"flake.nix",
				".hg",
				".bzr",
				"Makefile",
				"package.json",
				".git",
				".github",
				".svn",
				"Pipfile",
				"pyproject.toml",
				".pre-commit-config.yaml",
				".pre-commit-config.yml",
				".csproj",
				".sln",
				".nvim.lua",
			},

			-- Table of lsp clients to ignore by name
			-- eg: { "efm", ... }
			ignore_lsp = {},

			-- Don't calculate root dir on specific directories
			-- Ex: { "~/.cargo/*", ... }
			exclude_dirs = {},

			-- Show hidden files in telescope
			show_hidden = false,

			-- When set to false, you will get a message when project.nvim changes your
			-- directory.
			silent_chdir = true,

			-- What scope to change the directory, valid options are
			-- * global (default)
			-- * tab
			-- * win
			scope_chdir = "global",

			-- Path where project.nvim will store the project history for use in
			-- telescope
			datapath = vim.fn.stdpath("data"),
		})
	end,
}
