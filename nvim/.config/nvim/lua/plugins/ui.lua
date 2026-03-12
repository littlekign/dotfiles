-- UI / Themes
-- Purpose: Color schemes and visual theming
-- Plugins:
--   - catppuccin/nvim
--   - ellisonleao/gruvbox.nvim

return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("catppuccin")
		end,
	},
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = true,
	},
}
