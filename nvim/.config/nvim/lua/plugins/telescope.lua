-- Telescope
-- Purpose: Fuzzy finder for files, text, LSP symbols, and more
-- Plugins:
--   - nvim-telescope/telescope.nvim - Main fuzzy finder
--   - nvim-telescope/telescope-fzf-native.nvim - Faster sorting

return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "v0.2.1",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		opts = {
			defaults = {
				borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
			},
		},
	},
}
