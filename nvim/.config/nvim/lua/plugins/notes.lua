-- Note Taking
-- Purpose: Obsidian vault integration
-- Plugins:
--   - epwalsh/obsidian.nvim - Obsidian vault integration

return {
	{
		"epwalsh/obsidian.nvim",
		version = "*",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = {
			"BufReadPre " .. vim.fn.expand("~") .. "/notes/**.md",
			"BufNewFile " .. vim.fn.expand("~") .. "/notes/**.md",
		},
		cmd = { "ObsidianQuickSwitch", "ObsidianNew", "ObsidianSearch", "ObsidianToday", "ObsidianBacklinks" },
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function()
					vim.opt_local.conceallevel = 2
				end,
			})
		end,
		opts = {
			workspaces = {
				{ name = "notes", path = "~/notes" },
			},
			note_id_func = function(title)
				return title
			end,
			follow_url_func = function(url)
				vim.fn.jobstart({ "open", url })
			end,
		},
		-- Keymaps in config/keymaps.lua
	},
}
