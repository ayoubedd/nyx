-- Split/join code blocks. Not on treesj's default <space>m/j/s: <space> is the
-- leader and <leader>s is the search group.
return {
	"Wansmer/treesj",
	keys = {
		{ "<leader>m", "<cmd>TSJToggle<cr>", desc = "Split/join block" },
		{ "<leader>j", "<cmd>TSJJoin<cr>", desc = "Join block" },
		{ "<leader>k", "<cmd>TSJSplit<cr>", desc = "Split block" },
	},
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	opts = { use_default_keymaps = false },
}
