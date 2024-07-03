local opt = vim.opt
local g = vim.g
local o = vim.o

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
g.mapleader = " "
g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
opt.mouse = ""

-- Don't show the mode, since it's already in the status line
opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
opt.clipboard = "unnamedplus"

-- Enable break indent
opt.breakindent = true

-- Save undo history
opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
opt.ignorecase = true
opt.smartcase = true

-- Keep signcolumn on by default
opt.signcolumn = "yes"

-- Decrease update time
opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
opt.timeoutlen = 300

-- Configure how new splits should be opened
opt.splitright = true
opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
opt.list = false
-- opt.listchars = { tab = '» ', trail = '·', nbsp = '␣', eol = '↵' }
-- opt.listchars = { tab = ' ', trail = '·', nbsp = '␣', eol = '↵' }

-- Preview substitutions live, as you type!
opt.inccommand = "split"

-- Show which line your cursor is on
opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
opt.scrolloff = 10

opt.smarttab = true
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2

opt.termguicolors = true
o.guifont = "JetBrainsMono Nerd Font:h18"

o.ph = 10
o.pw = 5
