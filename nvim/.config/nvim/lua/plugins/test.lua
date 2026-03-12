-- Testing
-- Purpose: Run and view test results
-- Plugins:
--   - nvim-neotest/neotest - Test runner framework
--   - nvim-neotest/neotest-python - Python adapter for neotest

return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-neotest/neotest-python",
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-python")({
						runner = "pytest",
						python = function()
							local cwd = vim.fn.getcwd()
							return cwd .. "/.venv/bin/python"
						end,
					}),
				},
			})
			-- Keymaps in config/keymaps.lua
		end,
	},
}
