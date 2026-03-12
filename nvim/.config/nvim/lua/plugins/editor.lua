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

	-- Treesitter - better syntax highlighting and code navigation
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master", -- Pin to master branch for stable API
		build = ":TSUpdate",
		lazy = false, -- Treesitter should not be lazy-loaded
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"c",
					"go",
					"lua",
					"python",
					"query",
					"ruby",
					"vim",
					"vimdoc",
				},
				highlight = { enable = true },
				textobjects = {
					move = {
						enable = true,
						goto_next_start = {
							["]m"] = "@function.outer",
							["]]"] = "@class.outer",
						},
						goto_next_end = {
							["]M"] = "@function.outer",
							["]["] = "@class.outer",
						},
						goto_previous_start = {
							["[m"] = "@function.outer",
							["[["] = "@class.outer",
						},
						goto_previous_end = {
							["[M"] = "@function.outer",
							["[]"] = "@class.outer",
						},
					},
				},
			})
		end,
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
