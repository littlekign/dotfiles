-- Neovim Options
-- General editor settings, appearance, and behavior

-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

-- Line numbers
vim.opt.number = true

-- Clipboard integration (delayed for faster startup)
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- UI
vim.opt.updatetime = 250
vim.opt.signcolumn = "yes"
vim.opt.winborder = "single"

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Visual helpers
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split" -- Preview substitutions live

-- Indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.softtabstop = 2

-- Folding (using treesitter)
vim.opt.foldenable = true
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99 -- start with all folds open

vim.opt.foldtext = ""

-- LSP logging
vim.lsp.set_log_level("off")
