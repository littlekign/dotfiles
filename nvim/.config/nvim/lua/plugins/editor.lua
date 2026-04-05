-- Editor Enhancements
-- Purpose: Core editing and navigation improvements
-- Plugins:
--   - stevearc/oil.nvim - File explorer as a buffer
--   - nvim-treesitter/nvim-treesitter - Syntax parsing and highlighting
--   - nvim-treesitter/nvim-treesitter-textobjects - Navigate by function/class

return {
	-- Oil.nvim - edit directories like buffers
	{
		"stevearc/oil.nvim",
		opts = {},
	},

	-- Treesitter - syntax parsing and highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		lazy = false,
		config = function()
			require("nvim-treesitter").setup()
			require("nvim-treesitter").install({
				"c",
				"go",
				"lua",
				"python",
				"query",
				"ruby",
				"vim",
				"vimdoc",
			})
		end,
	},

	-- Treesitter text objects - navigate by function/class
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				move = { set_jumps = true },
			})
		end,
		-- Keymaps in config/keymaps.lua
	},

	-- Format on save
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "black" },
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_fallback = true,
				},
			})

			vim.api.nvim_create_user_command("Format", function()
				require("conform").format({ bufnr = vim.api.nvim_get_current_buf() })
			end, { desc = "Format current buffer" })
		end,
	},
}
