-- UI / Themes
-- Purpose: Color schemes, visual theming, and statusline
-- Plugins:
--   - catppuccin/nvim
--   - ellisonleao/gruvbox.nvim
--   - lualine.nvim

return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		-- config = function()
		-- 	vim.cmd.colorscheme("catppuccin")
		-- end,
	},
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = true,
	},
	-- Using Lazy
	{
		"navarasu/onedark.nvim",
		priority = 1000, -- make sure to load this before all the other start plugins
	},
	{
		"pmouraguedes/neodarcula.nvim",
		lazy = false,
		priority = 1000,
	},
	{
		"loctvl842/monokai-pro.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("monokai-pro").setup({
				filter = "pro",
				override = function()
					return {
						DiagnosticUnderlineError = { undercurl = false, underline = true },
						DiagnosticUnderlineWarn = { undercurl = false, underline = true },
						DiagnosticUnderlineInfo = { undercurl = false, underline = true },
						DiagnosticUnderlineHint = { undercurl = false, underline = true },
					}
				end,
			})
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				theme = "monokai-pro",
				section_separators = "",
				component_separators = "|",
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					{
						"branch",
						fmt = function(name)
							if name == "main" or name == "master" then
								return ""
							end
							return "b"
						end,
					},
					"diff",
					"diagnostics",
				},
				lualine_c = {
					{
						"filename",
						path = 4, -- relative to git root (falls back to cwd)
					},
				},
				lualine_x = {
					{
						function()
							local names = {}
							for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
								if _G._lsp_loading[client.name] then
									table.insert(names, "[" .. client.name .. "]")
								end
							end
							return table.concat(names, ", ")
						end,
					},
					{
						require("lazy.status").updates,
						cond = require("lazy.status").has_updates,
						color = { fg = "#ff9e64" },
					},
				},
				lualine_y = { "filetype" },
				lualine_z = { "location" },
			},
		},
	},
}
