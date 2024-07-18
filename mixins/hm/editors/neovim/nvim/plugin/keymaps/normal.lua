local set = vim.api.nvim_set_keymap

set("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Go to next buffer" })    -- Next buffer
set("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Go to preview buffer" }) -- Prev buffer

set("n", "<C-l>", "<C-w>l", {})                                                      -- Move to left split
set("n", "<C-h>", "<C-w>h", {})                                                      -- Move to right split
set("n", "<C-j>", "<C-w>j", {})                                                      -- Move to down split
set("n", "<C-k>", "<C-w>k", {})                                                      -- Move to upper split

set("n", "<leader>h", "<cmd>nohls<cr>", {
	desc = "No Highlight",
})                                                                             -- Turn off highlights

set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Toggle NvimTree" }) -- Toggle NvimTree
set("n", "<Esc>", "<cmd>nohls<cr>", { desc = "No Highlight" })                 -- Turn off highlights

set("n", "<left>", '<cmd>echo "Use h to move!!"<cr>', {})
set("n", "<right>", '<cmd>echo "Use l to move!!"<cr>', {})
set("n", "<up>", '<cmd>echo "Use k to move!!"<cr>', {})
set("n", "<down>", '<cmd>echo "Use j to move!!"<cr>', {})

set("n", "<C-s>", "<cmd>w<cr>", { desc = "Save file" })         -- Save
set("n", "<leader>qq", "<cmd>qa!<cr>", { desc = "Force quit" }) -- Force quite

-- Toggle hlsearch if it's on, otherwise just do "enter"
set("n", "<cr>", "", {
	expr = true,
	desc = "Toggle search highlight",
	callback = function()
		---@diagnostic disable-next-line: undefined-field
		if vim.opt.hlsearch:get() then
			vim.cmd.nohl()
		end
	end,
})

-- These mappings control the size of splits (height/width)
set("n", "<M-l>", "<c-w>5<", { desc = "Decrease width of split" })
set("n", "<M-h>", "<c-w>5>", { desc = "Increase width of split" })
set("n", "<M-k>", "<C-W>+", { desc = "Increase height of split" })
set("n", "<M-j>", "<C-W>-", { desc = "Decrease height of split" })
set("n", "<M-=>", "<C-W>=", { desc = "Equalize split sizes" })

-- restore the session for the current directory
set("n", "<leader>pr", [[<cmd>lua require("persistence").load()<cr>]], { desc = "Restore session" })

-- restore the last session
set("n", "<leader>pl", [[<cmd>lua require("persistence").load({ last = true })<cr>]], { desc = "Restore last session" })
set("n", "<leader>c", "<cmd>bdelete<cr>", { desc = "Close buffer" })

set("n", "<leader>s", "", { desc = "Search" })
set("n", "<leader>sf", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
set("n", "<leader>sb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
set("n", "<leader>sg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
set("n", "<leader>sr", "<cmd>Telescope registers<cr>", { desc = "Search registers" })


set("n", "<leader>s/", "<Plug>(leap-forward)", { desc = "Leap backward" })
set("n", "<leader>s?", "<Plug>(leap-backward)", { desc = "Leap backward" })

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
	"<leader>lt",
	":Telescope lsp_type_definitions<cr>",
	{ desc = "Type Definition", noremap = true, silent = true }
)
set("n", "<leader>ld", ":Telescope lsp_definitions<cr>", { desc = "Go To Definition", noremap = true, silent = true })
set("n", "<leader>lR", ":Telescope lsp_references<cr>", { desc = "References", noremap = true, silent = true })

-- LSP_Saga
set("n", "<leader>lk", ":Lspsaga hover_doc<cr>", { desc = "Hover Docs", noremap = true, silent = true })
set("n", "gd", ":Lspsaga goto_definition<cr>", { desc = "Goto Definition", noremap = true, silent = true })
set("n", "<leader>lr", ":Lspsaga rename<cr>", { desc = "Rename", noremap = true, silent = true })
set("n", "<leader>la", ":Lspsaga code_action<cr>", { desc = "Code Action", noremap = true, silent = true })

set(
	"n",
	"<leader>le",
	":Lspsaga show_line_diagnostics<cr>",
	{ desc = "Show Line Diagnostics", noremap = true, silent = true }
)
set(
	"n",
	"<leader>ln",
	":Lspsaga diagnostic_jump_next<cr>",
	{ desc = "Go To Next Diagnostic", noremap = true, silent = true }
)
set(
	"n",
	"<leader>lp",
	":Lspsaga diagnostic_jump_prev<cr>",
	{ desc = "Go To Previous Diagnostic", noremap = true, silent = true }
)
set("n", "<leader>lo", ":Lspsaga outline<cr>", { desc = "LSP Saga outline", noremap = true, silent = true })
