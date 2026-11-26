local set = vim.api.nvim_set_keymap

set("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Go to next buffer" }) -- Next buffer
set("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Go to preview buffer" }) -- Prev buffer

set("n", "<C-l>", "<C-w>l", {}) -- Move to left split
set("n", "<C-h>", "<C-w>h", {}) -- Move to right split
set("n", "<C-j>", "<C-w>j", {}) -- Move to down split
set("n", "<C-k>", "<C-w>k", {}) -- Move to upper split

set("n", "<Esc>", "<cmd>nohls<cr>", { desc = "No Highlight" }) -- Turn off highlights

set("n", "<left>", '<cmd>echo "Use h to move!!"<cr>', {})
set("n", "<right>", '<cmd>echo "Use l to move!!"<cr>', {})
set("n", "<up>", '<cmd>echo "Use k to move!!"<cr>', {})
set("n", "<down>", '<cmd>echo "Use j to move!!"<cr>', {})

set("n", "<leader>qq", "<cmd>qa!<cr>", { desc = "Force quit" }) -- Force quite
set("n", "<leader>c", "<cmd>bd<cr>", { desc = "Force quit" }) -- Force quite

-- Toggle hlsearch if it's on, otherwise just do "enter"
set("n", "<cr>", "", {
	expr = true,
	desc = "Toggle search highlight",
	-- An expr map must return the keys to run: "" swallows <CR> to clear the
	-- highlight; otherwise <CR> passes through (quickfix jumps, cursor down).
	callback = function()
		if vim.v.hlsearch == 1 then
			vim.cmd.nohlsearch()
			return ""
		end
		return "<CR>"
	end,
})

-- These mappings control the size of splits (height/width)
set("n", "<M-l>", "<c-w>5<", { desc = "Decrease width of split" })
set("n", "<M-h>", "<c-w>5>", { desc = "Increase width of split" })
set("n", "<M-k>", "<C-W>+", { desc = "Increase height of split" })
set("n", "<M-j>", "<C-W>-", { desc = "Decrease height of split" })
set("n", "<M-=>", "<C-W>=", { desc = "Equalize split sizes" })

set("n", "<leader>s", "", { desc = "Search" })
set("n", "<leader>sf", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
set("n", "<leader>sb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
set("n", "<leader>sg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
set("n", "<leader>sr", "<cmd>Telescope registers<cr>", { desc = "Search registers" })

-- LSP Keymaps
set("n", "<leader>li", ":LspInfo<cr>", { desc = "Connected Language Servers", noremap = true, silent = true })
set(
	"n",
	"<leader>lK",
	":lua vim.lsp.buf.signature_help()<cr>",
	{ desc = "Signature Help", noremap = true, silent = true }
)
set("n", "<leader>lD", ":Telescope diagnostics<cr>", { desc = "Telescope Diagnostic", noremap = true, silent = true })
set(
	"n",
	"<leader>ls",
	":lua require'telescope.builtin'.lsp_references{}<cr>",
	{ desc = "Telescope symbols", noremap = true, silent = true }
)
set(
	"n",
	"<leader>lS",
	":lua require'telescope.builtin'.lsp_workspace_symbols{}<cr>",
	{ desc = "Telescope workspace symbols", noremap = true, silent = true }
)

-- Git keymaps
set(
	"n",
	"<leader>gc",
	":lua require'telescope.builtin'.git_commits{}<cr>",
	{ desc = "Telescope git commits", noremap = true, silent = true }
)
set(
	"n",
	"<leader>gb",
	":lua require'telescope.builtin'.git_branches{}<cr>",
	{ desc = "Telescope git branches", noremap = true, silent = true }
)
set(
	"n",
	"<leader>gs",
	":lua require'telescope.builtin'.git_status{}<cr>",
	{ desc = "Telescope git status", noremap = true, silent = true }
)

set(
	"n",
	"<leader>lt",
	":Telescope lsp_type_definitions<cr>",
	{ desc = "Type Definition", noremap = true, silent = true }
)
set("n", "<leader>ld", ":Telescope lsp_definitions<cr>", { desc = "Go To Definition", noremap = true, silent = true })
set("n", "<leader>lR", ":Telescope lsp_references<cr>", { desc = "References", noremap = true, silent = true })

-- vim.keymap.set, not `set` (nvim_set_keymap): these take Lua functions.
local map = vim.keymap.set
map("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename" })
map({ "n", "x" }, "<leader>la", vim.lsp.buf.code_action, { desc = "Code Action" })

-- Diagnostics (built in; floats are rounded with the source, see config/lsp.lua)
map("n", "<leader>le", vim.diagnostic.open_float, { desc = "Show Line Diagnostics" })
map("n", "<leader>ln", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go To Next Diagnostic" })
map("n", "<leader>lp", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go To Previous Diagnostic" })
map("n", "<leader>lo", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Document Symbols" })
map("n", "<leader>lh", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, { desc = "Toggle Inlay Hints" })
