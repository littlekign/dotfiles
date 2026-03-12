-- Git Integration
-- Purpose: Git commands and diff viewing
-- Plugins:
--   - tpope/vim-fugitive - Git commands in Vim
--   - sindrets/diffview.nvim - Better diff and merge tool

return {
	{
		"tpope/vim-fugitive",
		name = "vim-fugitive",
	},
	{
		"sindrets/diffview.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		-- Keymaps in config/keymaps.lua
	},
}
