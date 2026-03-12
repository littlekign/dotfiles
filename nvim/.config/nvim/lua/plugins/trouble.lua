-- Trouble
-- Purpose: Better UI for diagnostics, quickfix, and location lists
-- Plugins:
--   - folke/trouble.nvim - Pretty lists for diagnostics and more

return {
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
		-- Keymaps in config/keymaps.lua
	},
}
