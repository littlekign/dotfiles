-- Note Taking
-- Purpose: Markdown rendering and note organization
-- Plugins:
--   - nvim-neorg/neorg - Structured note taking
--   - MeanderingProgrammer/render-markdown.nvim - Markdown preview

return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		opts = {},
		-- Keymaps in config/keymaps.lua
	},
	{
		"nvim-neorg/neorg",
		lazy = false,
		version = "*",
		dependencies = { "nvim-neorg/tree-sitter-norg" },
		config = function()
			require("neorg").setup({
				load = {
					["core.defaults"] = {},
					["core.concealer"] = {},
					["core.dirman"] = {
						config = {
							workspaces = {
								notes = "~/notes",
							},
							default_workspace = "notes",
						},
					},
				},
			})
			vim.wo.foldlevel = 99
			vim.wo.conceallevel = 2
			-- Keymaps in config/keymaps.lua
		end,
	},
}
